[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

function Test-OneDriveInstalled {
    $applicationPaths = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe')
        (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
    )
    $uninstallPaths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe'
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe'
    )

    return $null -ne (@($applicationPaths + $uninstallPaths) |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1)
}

Write-SetupSection -Message 'Desativando sincronizacao do OneDrive'
Set-SetupRegistryValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' `
    -Name 'DisableFileSyncNGSC' `
    -Value 1

Remove-ItemProperty `
    -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' `
    -Name 'OneDrive' `
    -ErrorAction SilentlyContinue

Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force

Write-SetupSection -Message 'Desinstalando OneDrive'
$oneDriveInstalled = Test-OneDriveInstalled
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue

if ($oneDriveInstalled -and $null -ne $winget) {
    & winget.exe uninstall `
        --id Microsoft.OneDrive `
        --exact `
        --source winget `
        --silent `
        --accept-source-agreements `
        --disable-interactivity

    Start-Sleep -Seconds 1
    $oneDriveInstalled = Test-OneDriveInstalled
}

if ($oneDriveInstalled) {
    $setupCandidates = @(
        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
    )

    foreach ($setupPath in $setupCandidates) {
        if (Test-Path -LiteralPath $setupPath) {
            & $setupPath /uninstall
            Start-Sleep -Seconds 1
            $oneDriveInstalled = Test-OneDriveInstalled
            if (-not $oneDriveInstalled) {
                break
            }
        }
    }
}

if ($oneDriveInstalled) {
    throw 'O OneDrive continua instalado depois das tentativas de remocao.'
}

Write-Host 'OneDrive ausente e desativado por politica local.' -ForegroundColor Green

$oneDriveFolder = Join-Path $env:USERPROFILE 'OneDrive'
if (Test-Path -LiteralPath $oneDriveFolder) {
    Write-Warning "A pasta '$oneDriveFolder' foi preservada para evitar perda de arquivos."
}
