[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

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
$uninstalled = $false
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue

if ($null -ne $winget) {
    & winget.exe uninstall `
        --id Microsoft.OneDrive `
        --exact `
        --silent `
        --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        $uninstalled = $true
    }
}

if (-not $uninstalled) {
    $setupCandidates = @(
        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
    )

    foreach ($setupPath in $setupCandidates) {
        if (Test-Path -LiteralPath $setupPath) {
            Invoke-SetupNativeCommand `
                -FilePath $setupPath `
                -ArgumentList @('/uninstall')
            $uninstalled = $true
            break
        }
    }
}

if ($uninstalled) {
    Write-Host 'OneDrive desinstalado e desativado por politica local.' -ForegroundColor Green
} else {
    Write-Host 'OneDrive nao estava instalado; a politica de bloqueio foi mantida.' -ForegroundColor Green
}

$oneDriveFolder = Join-Path $env:USERPROFILE 'OneDrive'
if (Test-Path -LiteralPath $oneDriveFolder) {
    Write-Warning "A pasta '$oneDriveFolder' foi preservada para evitar perda de arquivos."
}
