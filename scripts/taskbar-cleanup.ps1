[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

Write-SetupSection -Message 'Barra de tarefas'
$advancedPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-SetupRegistryValue -Path $advancedPath -Name 'TaskbarDa' -Value 0
Set-SetupRegistryValue -Path $advancedPath -Name 'ShowTaskViewButton' -Value 0

Set-SetupRegistryValue `
    -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' `
    -Name 'SearchboxTaskbarMode' `
    -Value 1

Write-SetupSection -Message 'Conteudo sugerido'
$contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
foreach ($name in @(
    'SubscribedContent-338388Enabled'
    'SubscribedContent-338389Enabled'
    'SubscribedContent-338387Enabled'
    'SubscribedContent-310093Enabled'
)) {
    Set-SetupRegistryValue -Path $contentPath -Name $name -Value 0
}

Restart-SetupExplorer
Write-Host 'Barra de tarefas atualizada.' -ForegroundColor Green
