[CmdletBinding()]
param(
    [string] $PublicKey
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
if ([string]::IsNullOrWhiteSpace($PublicKey)) {
    $PublicKey = $config.RemoteAccess.PublicKey
}

Write-SetupSection -Message 'Instalando OpenSSH Server'
$capabilityName = 'OpenSSH.Server~~~~0.0.1.0'
$capability = Get-WindowsCapability -Online -Name $capabilityName

if ($capability.State -ne 'Installed') {
    $result = Add-WindowsCapability -Online -Name $capabilityName
    if ($result.RestartNeeded) {
        Write-Warning 'O Windows solicitou uma reinicializacao para concluir o OpenSSH.'
    }
}

$sshProgramDataPath = Join-Path $env:ProgramData 'ssh'
$sshdConfigPath = Join-Path $sshProgramDataPath 'sshd_config'
$authorizedKeysPath = Join-Path $sshProgramDataPath 'administrators_authorized_keys'
$sshdExecutablePath = Join-Path $env:SystemRoot 'System32\OpenSSH\sshd.exe'

if (-not (Test-Path -LiteralPath $sshdConfigPath)) {
    throw "Configuracao do OpenSSH nao encontrada: $sshdConfigPath"
}

$sshdConfig = Get-Content -LiteralPath $sshdConfigPath -Raw
$hasAdministratorsMatch = $sshdConfig -match '(?im)^\s*Match\s+Group\s+administrators\s*$'
$hasAdministratorsKeyFile = $sshdConfig -match `
    '(?im)^\s*AuthorizedKeysFile\s+__PROGRAMDATA__/ssh/administrators_authorized_keys\s*$'

if (-not ($hasAdministratorsMatch -and $hasAdministratorsKeyFile)) {
    $backupPath = "$sshdConfigPath.pcsetup.bak"
    Copy-Item -LiteralPath $sshdConfigPath -Destination $backupPath -Force

    Add-Content `
        -LiteralPath $sshdConfigPath `
        -Value "`r`nMatch Group administrators`r`n       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys" `
        -Encoding Ascii

    try {
        Invoke-SetupNativeCommand `
            -FilePath $sshdExecutablePath `
            -ArgumentList @('-t', '-f', $sshdConfigPath)
    } catch {
        Copy-Item -LiteralPath $backupPath -Destination $sshdConfigPath -Force
        throw 'A configuracao SSH gerada era invalida e foi restaurada a partir do backup.'
    }
}

$service = Get-Service -Name sshd -ErrorAction Stop
Set-Service -Name sshd -StartupType Automatic
if ($service.Status -ne 'Running') {
    Start-Service -Name sshd
}

Write-SetupSection -Message 'Restringindo o firewall a rede local'
$defaultRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
if ($null -ne $defaultRule) {
    $defaultRule | Disable-NetFirewallRule | Out-Null
}

$localRuleName = 'PCSetup-OpenSSH-LocalSubnet'
$localRule = Get-NetFirewallRule -Name $localRuleName -ErrorAction SilentlyContinue
if ($null -eq $localRule) {
    $localRule = New-NetFirewallRule `
        -Name $localRuleName `
        -DisplayName 'OpenSSH Server - rede local' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22 `
        -RemoteAddress LocalSubnet
} else {
    $localRule | Set-NetFirewallRule -Enabled True | Out-Null
    $localRule | Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter -RemoteAddress LocalSubnet | Out-Null
}

if ([string]::IsNullOrWhiteSpace($PublicKey)) {
    Write-Host ''
    Write-Host 'Cole uma chave publica SSH ou pressione Enter para configurar depois.' -ForegroundColor Cyan
    Write-Host 'Nunca cole uma chave privada.' -ForegroundColor Yellow
    $PublicKey = Read-Host 'Chave publica'
}

if (-not [string]::IsNullOrWhiteSpace($PublicKey)) {
    if ($PublicKey -notmatch '^ssh-(ed25519|rsa|ecdsa-[^ ]+)\s+[A-Za-z0-9+/=]+(?:\s+.*)?$') {
        throw 'O valor informado nao parece ser uma chave publica SSH valida.'
    }

    $authorizedKeysDirectory = Split-Path -Parent $authorizedKeysPath
    $null = New-Item -Path $authorizedKeysDirectory -ItemType Directory -Force

    $existingKeys = @()
    if (Test-Path -LiteralPath $authorizedKeysPath) {
        $existingKeys = @(Get-Content -LiteralPath $authorizedKeysPath)
    }

    if ($existingKeys -notcontains $PublicKey.Trim()) {
        Add-Content -LiteralPath $authorizedKeysPath -Value $PublicKey.Trim() -Encoding Ascii
    }

    $acl = Get-Acl -LiteralPath $authorizedKeysPath
    $acl.SetAccessRuleProtection($true, $false)

    foreach ($accessRule in @($acl.Access)) {
        $acl.RemoveAccessRuleSpecific($accessRule)
    }

    foreach ($sidValue in @('S-1-5-32-544', 'S-1-5-18')) {
        $sid = [System.Security.Principal.SecurityIdentifier]::new($sidValue)
        $accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $sid,
            [System.Security.AccessControl.FileSystemRights]::FullControl,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $null = $acl.AddAccessRule($accessRule)
    }

    Set-Acl -LiteralPath $authorizedKeysPath -AclObject $acl

    Write-Host 'Chave publica instalada para contas administradoras.' -ForegroundColor Green
} else {
    Write-Warning 'O servidor esta ativo, mas nenhuma chave publica foi instalada.'
}

Restart-Service -Name sshd -Force
$sshReady = Test-NetConnection `
    -ComputerName '127.0.0.1' `
    -Port 22 `
    -InformationLevel Quiet `
    -WarningAction SilentlyContinue

if (-not $sshReady) {
    throw 'O servico sshd iniciou, mas a porta 22 local nao respondeu.'
}

Write-SetupSection -Message 'Dados para conexao'
$addresses = Get-NetIPAddress `
    -AddressFamily IPv4 `
    -AddressState Preferred `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
    Select-Object -ExpandProperty IPAddress -Unique

Write-Host ('Usuario: {0}\{1}' -f $env:USERDOMAIN, $env:USERNAME)
Write-Host ('IPv4: {0}' -f ($addresses -join ', '))
Write-Host 'Porta: 22'

$hostKeyPath = Join-Path $sshProgramDataPath 'ssh_host_ed25519_key.pub'
if (Test-Path -LiteralPath $hostKeyPath) {
    Write-Host 'Fingerprint do servidor:'
    & ssh-keygen.exe -lf $hostKeyPath
}
