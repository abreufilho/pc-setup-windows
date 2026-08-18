[CmdletBinding()]
param(
    [uri] $AvatarUri
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
if ($null -eq $AvatarUri) {
    $AvatarUri = [uri] $config.General.AvatarUri
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$downloadPath = Join-Path $env:TEMP ('pc-setup-avatar-{0}.png' -f [guid]::NewGuid().ToString('N'))

try {
    Write-SetupSection -Message 'Baixando avatar'
    Invoke-WebRequest -Uri $AvatarUri -OutFile $downloadPath -UseBasicParsing

    if ((Get-Item -LiteralPath $downloadPath).Length -lt 512) {
        throw 'A imagem baixada e invalida ou esta incompleta.'
    }

    $userSid = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\$userSid"
    $destinationDirectory = Join-Path $env:PUBLIC 'AccountPictures\PCSetup'
    $destinationPath = Join-Path $destinationDirectory ("{0}.png" -f $env:USERNAME)

    $null = New-Item -Path $registryPath -Force
    $null = New-Item -Path $destinationDirectory -ItemType Directory -Force
    Copy-Item -LiteralPath $downloadPath -Destination $destinationPath -Force

    foreach ($size in @(32, 40, 48, 96, 192, 240, 448)) {
        Set-SetupRegistryValue `
            -Path $registryPath `
            -Name ("Image{0}" -f $size) `
            -Value $destinationPath `
            -Type String
    }

    Write-Host 'Avatar configurado. Saia e entre novamente para atualizar todas as telas.' -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $downloadPath) {
        Remove-Item -LiteralPath $downloadPath -Force
    }
}
