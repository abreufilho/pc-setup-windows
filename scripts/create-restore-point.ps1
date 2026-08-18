[CmdletBinding()]
param(
    [string] $Description = 'Antes do PC Setup Windows'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
$propertyName = 'SystemRestorePointCreationFrequency'
$originalProperties = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue
$hadOriginalValue = $null -ne $originalProperties -and `
    $originalProperties.PSObject.Properties.Name -contains $propertyName
$originalValue = $null

if ($hadOriginalValue) {
    $originalValue = $originalProperties.$propertyName
}

Write-SetupSection -Message 'Criando ponto de restauracao'

try {
    Enable-ComputerRestore -Drive ("{0}\" -f $env:SystemDrive) -ErrorAction Stop
    Set-SetupRegistryValue `
        -Path $registryPath `
        -Name $propertyName `
        -Value 0

    Checkpoint-Computer `
        -Description $Description `
        -RestorePointType MODIFY_SETTINGS `
        -ErrorAction Stop

    Write-Host 'Ponto de restauracao criado com sucesso.' -ForegroundColor Green
} catch {
    Write-Warning "O Windows nao permitiu criar o ponto de restauracao: $($_.Exception.Message)"
    Write-Warning 'O setup continuara; logs e scripts idempotentes permanecem disponiveis.'
} finally {
    if ($hadOriginalValue) {
        Set-SetupRegistryValue `
            -Path $registryPath `
            -Name $propertyName `
            -Value $originalValue
    } else {
        Remove-ItemProperty `
            -Path $registryPath `
            -Name $propertyName `
            -ErrorAction SilentlyContinue
    }
}
