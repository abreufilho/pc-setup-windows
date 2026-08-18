[CmdletBinding()]
param(
    [ValidateSet('All', 'Core', 'Development', 'Personal')]
    [string] $Group = 'All'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
$packages = @($config.Programs | Where-Object { $Group -eq 'All' -or $_.Group -eq $Group })

Write-SetupSection -Message 'Preparando WinGet'
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue

if ($null -eq $winget) {
    Write-Host 'Tentando registrar o App Installer para o usuario atual...' -ForegroundColor Yellow
    Add-AppxPackage `
        -RegisterByFamilyName `
        -MainPackage 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe' `
        -ErrorAction SilentlyContinue
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
}

if ($null -eq $winget) {
    throw 'WinGet nao esta disponivel. Atualize o App Installer pela Microsoft Store e execute novamente.'
}

Invoke-SetupNativeCommand `
    -FilePath 'winget.exe' `
    -ArgumentList @('source', 'update', '--accept-source-agreements')

$failures = New-Object System.Collections.Generic.List[string]

foreach ($package in $packages) {
    Write-Host ''
    Write-Host ("Verificando {0}..." -f $package.Name) -ForegroundColor Yellow

    $listArguments = @(
        'list'
        '--id', $package.Id
        '--exact'
        '--source', $package.Source
        '--accept-source-agreements'
    )

    $null = & winget.exe @listArguments 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ("{0} ja esta instalado." -f $package.Name) -ForegroundColor Green
        continue
    }

    $installArguments = @(
        'install'
        '--id', $package.Id
        '--exact'
        '--source', $package.Source
        '--accept-source-agreements'
        '--accept-package-agreements'
        '--silent'
        '--no-upgrade'
    )

    try {
        Invoke-SetupNativeCommand -FilePath 'winget.exe' -ArgumentList $installArguments
        Write-Host ("{0} instalado com sucesso." -f $package.Name) -ForegroundColor Green
    } catch {
        $failures.Add(("{0} ({1})" -f $package.Name, $package.Id))
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-SetupSection -Message 'Resumo dos programas'
if ($failures.Count -gt 0) {
    Write-Host ('Falharam: {0}' -f ($failures -join ', ')) -ForegroundColor Red
    throw 'Uma ou mais instalacoes falharam.'
}

Write-Host 'Todos os programas selecionados estao instalados.' -ForegroundColor Green
