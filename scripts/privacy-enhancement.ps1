[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

Write-SetupSection -Message 'Historico de atividades'
Set-SetupRegistryValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name 'EnableActivityFeed' `
    -Value 0
Set-SetupRegistryValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name 'PublishUserActivities' `
    -Value 0
Set-SetupRegistryValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name 'UploadUserActivities' `
    -Value 0

Write-SetupSection -Message 'Diagnosticos e experiencias personalizadas'
Set-SetupRegistryValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
    -Name 'AllowTelemetry' `
    -Value 0
Set-SetupRegistryValue `
    -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' `
    -Name 'TailoredExperiencesWithDiagnosticDataEnabled' `
    -Value 0

Write-SetupSection -Message 'Publicidade e sugestoes'
Set-SetupRegistryValue `
    -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
    -Name 'Enabled' `
    -Value 0
Set-SetupRegistryValue `
    -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
    -Name 'SubscribedContent-338389Enabled' `
    -Value 0
Set-SetupRegistryValue `
    -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' `
    -Name 'NumberOfSIUFInPeriod' `
    -Value 0

Write-Host ''
Write-Host 'Ajustes aplicados sem desativar Defender, Windows Update ou servicos de diagnostico.' -ForegroundColor Green
Write-Host 'Algumas edicoes do Windows impõem um nivel minimo de dados obrigatorios.' -ForegroundColor Yellow
