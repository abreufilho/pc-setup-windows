[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$testsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $testsPath
$failures = New-Object System.Collections.Generic.List[string]

Write-Host 'Validando sintaxe PowerShell...' -ForegroundColor Cyan
$powerShellFiles = @(
    Get-ChildItem -LiteralPath $rootPath -Recurse -File |
        Where-Object { $_.Extension -in @('.ps1', '.psd1', '.psm1') }
)

foreach ($file in $powerShellFiles) {
    $tokens = $null
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref] $tokens,
        [ref] $parseErrors
    )

    foreach ($parseError in @($parseErrors)) {
        $failures.Add((
            '{0}:{1}: {2}' -f $file.FullName, $parseError.Extent.StartLineNumber, $parseError.Message
        ))
    }
}

Write-Host 'Validando configuracao...' -ForegroundColor Cyan
$configPath = Join-Path $rootPath 'config\setup.psd1'
$config = Import-PowerShellDataFile -Path $configPath
$packageIds = @($config.Programs | ForEach-Object { $_.Id })
$duplicateIds = @($packageIds | Group-Object | Where-Object { $_.Count -gt 1 })

foreach ($duplicate in $duplicateIds) {
    $failures.Add("Pacote duplicado na configuracao: $($duplicate.Name)")
}

if ($config.RemoteAccess.PublicKey -notmatch '^ssh-(ed25519|rsa|ecdsa-[^ ]+)\s+[A-Za-z0-9+/=]+(?:\s+.*)?$') {
    $failures.Add('A chave publica SSH da configuracao e invalida.')
}

if ($config.RecommendedScripts[0] -ne 'enable-ssh.ps1') {
    $failures.Add('O preset recomendado deve iniciar habilitando o SSH.')
}

if ($config.RecommendedScripts[1] -ne 'create-restore-point.ps1') {
    $failures.Add('O preset recomendado deve criar um ponto de restauracao antes dos ajustes.')
}

if ($config.RecommendedScripts[2] -ne 'remove-onedrive.ps1') {
    $failures.Add('O preset recomendado deve remover o OneDrive antes dos programas.')
}

if ($config.RecommendedScripts[3] -ne 'debloat.ps1') {
    $failures.Add('O preset recomendado deve executar a limpeza agressiva antes dos programas.')
}

foreach ($scriptName in $config.RecommendedScripts) {
    $scriptPath = Join-Path $rootPath ("scripts\{0}" -f $scriptName)
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        $failures.Add("Script recomendado nao encontrado: $scriptName")
    }
}

foreach ($protectedApp in @(
    'Microsoft.SecHealthUI'
    'Microsoft.WindowsStore'
    'Microsoft.DesktopAppInstaller'
)) {
    if ($config.Cleanup.Apps -contains $protectedApp) {
        $failures.Add("Aplicativo protegido presente na limpeza agressiva: $protectedApp")
    }

    if ($config.Cleanup.ProtectedApps -notcontains $protectedApp) {
        $failures.Add("Aplicativo obrigatorio ausente da lista de protecao: $protectedApp")
    }
}

if ($config.Cleanup.Mode -ne 'Aggressive' -or $config.Cleanup.RequireConfirmation) {
    $failures.Add('O preset pos-formatacao deve manter a limpeza agressiva e nao interativa.')
}

Write-Host 'Procurando regressões destrutivas conhecidas...' -ForegroundColor Cyan
$forbiddenPatterns = @(
    @{ Pattern = 'Microsoft\.SecHealthUI'; Message = 'Nao remover Windows Security.' }
    @{ Pattern = 'DisablePagingExecutive'; Message = 'Nao aplicar tweak global de paginacao.' }
    @{ Pattern = 'NetworkThrottlingIndex'; Message = 'Nao aplicar tweak global de rede.' }
    @{ Pattern = 'Set-Service.+WSearch.+Disabled'; Message = 'Nao desativar Windows Search.' }
    @{ Pattern = 'Set-Service.+SysMain.+Disabled'; Message = 'Nao desativar SysMain.' }
    @{ Pattern = 'Set-Service.+ssh-agent'; Message = 'O servidor SSH nao precisa iniciar o ssh-agent.' }
)

$productionFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $rootPath 'scripts') -Recurse -File |
        Where-Object { $_.Extension -in @('.ps1', '.psm1') }
)

foreach ($file in $productionFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($rule in $forbiddenPatterns) {
        if ($content -match $rule.Pattern) {
            $failures.Add(("{0}: {1}" -f $file.FullName, $rule.Message))
        }
    }
}

Write-Host 'Validando launcher...' -ForegroundColor Cyan
$launcherPath = Join-Path $rootPath 'setup.bat'
$launcherContent = Get-Content -LiteralPath $launcherPath -Raw
$installerPath = Join-Path $rootPath 'install.bat'
$installerContent = Get-Content -LiteralPath $installerPath -Raw
$bootstrapPath = Join-Path $rootPath 'bootstrap.ps1'
$bootstrapContent = Get-Content -LiteralPath $bootstrapPath -Raw

if ($launcherContent -notmatch '(?i)powershell\.exe\s+-NoLogo\s+-NoExit\s+-NoProfile.+-File\s+"%SETUP_ENTRYPOINT%"') {
    $failures.Add('setup.bat deve manter o PowerShell aberto com -NoExit.')
}

if ($installerContent -notmatch '(?i)Invoke-WebRequest.+BOOTSTRAP_URL.+BOOTSTRAP_PATH') {
    $failures.Add('install.bat deve baixar o bootstrap mais recente.')
}

if ($installerContent -notmatch '(?i)-File\s+"%BOOTSTRAP_PATH%"') {
    $failures.Add('install.bat deve executar o bootstrap baixado.')
}

if ($installerContent -match '(?i)\biex\b|Invoke-Expression') {
    $failures.Add('install.bat nao deve executar conteudo remoto em memoria.')
}

if ($bootstrapContent -match 'pc-setup-windows-\{0\}') {
    $failures.Add('bootstrap.ps1 nao deve criar destinos com timestamp.')
}

if ($bootstrapContent -notmatch 'Join-Path \$env:USERPROFILE ''pc-setup-windows''') {
    $failures.Add('bootstrap.ps1 deve atualizar sempre o mesmo destino.')
}

if ($bootstrapContent -notmatch "\[string\] \`$Preset = 'Recommended'") {
    $failures.Add('bootstrap.ps1 deve executar o preset recomendado por padrao.')
}

if ($bootstrapContent -notmatch '(?s)Start-Process.+-Verb RunAs.+-Wait.+-PassThru') {
    $failures.Add('bootstrap.ps1 deve aguardar o setup elevado diretamente.')
}

if ($bootstrapContent -match 'Start-Process -FilePath \(Join-Path \$destinationPath ''setup\.bat''\)') {
    $failures.Add('bootstrap.ps1 nao deve depender de outro launcher BAT.')
}

if ($failures.Count -gt 0) {
    Write-Host ''
    foreach ($failure in $failures) {
        Write-Host "[FALHA] $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host ''
Write-Host ("QA concluido: {0} arquivos PowerShell validos." -f $powerShellFiles.Count) -ForegroundColor Green
