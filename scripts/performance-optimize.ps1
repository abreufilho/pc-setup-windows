[CmdletBinding()]
param(
    [ValidateSet('Balanced', 'HighPerformance')]
    [string] $PowerPlan
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
if ([string]::IsNullOrWhiteSpace($PowerPlan)) {
    $PowerPlan = $config.General.PowerPlan
}

Write-SetupSection -Message 'Ajustes conservadores de desempenho'
Set-SetupRegistryValue `
    -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' `
    -Name 'VisualFXSetting' `
    -Value 2

Set-SetupRegistryValue `
    -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' `
    -Name 'MinAnimate' `
    -Value '0' `
    -Type String

$scheme = 'SCHEME_BALANCED'
if ($PowerPlan -eq 'HighPerformance') {
    $scheme = 'SCHEME_MIN'
}

Invoke-SetupNativeCommand -FilePath 'powercfg.exe' -ArgumentList @('/setactive', $scheme)

Write-Host "Plano de energia ativo: $PowerPlan" -ForegroundColor Green
Write-Host 'Tweaks de memoria, paginacao, rede e servicos foram intencionalmente evitados.' -ForegroundColor Green
