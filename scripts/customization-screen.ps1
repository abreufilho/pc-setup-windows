[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

Write-SetupSection -Message 'Tema escuro'
$themePath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
Set-SetupRegistryValue -Path $themePath -Name 'SystemUsesLightTheme' -Value 0
Set-SetupRegistryValue -Path $themePath -Name 'AppsUseLightTheme' -Value 0
Set-SetupRegistryValue -Path $themePath -Name 'EnableTransparency' -Value 0

Write-SetupSection -Message 'Area de trabalho'
Set-SetupRegistryValue `
    -Path 'HKCU:\Control Panel\Desktop' `
    -Name 'WallPaper' `
    -Value '' `
    -Type String
Set-SetupRegistryValue `
    -Path 'HKCU:\Control Panel\Colors' `
    -Name 'Background' `
    -Value '50 50 50' `
    -Type String

Write-SetupSection -Message 'Alinhamento da barra de tarefas'
Set-SetupRegistryValue `
    -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
    -Name 'TaskbarAl' `
    -Value 0

$refreshProcess = Start-Process `
    -FilePath 'rundll32.exe' `
    -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' `
    -Wait `
    -PassThru

if ($refreshProcess.ExitCode -ne 0) {
    Write-Warning 'O papel de parede sera atualizado no proximo login.'
}

Write-Host 'Personalizacao aplicada. A escala de exibicao foi preservada.' -ForegroundColor Green
