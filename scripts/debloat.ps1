[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch] $RequireConfirmation
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
$apps = @($config.Cleanup.Apps)
$protectedApps = @($config.Cleanup.ProtectedApps)
$shouldConfirm = $RequireConfirmation -or $config.Cleanup.RequireConfirmation

Write-SetupSection -Message 'Limpeza agressiva pos-formatacao'
Write-Host ('Modo: {0}' -f $config.Cleanup.Mode) -ForegroundColor Yellow
Write-Host ('Aplicativos selecionados: {0}' -f $apps.Count)
Write-Host ('Protegidos: {0}' -f ($protectedApps -join ', ')) -ForegroundColor Green

if ($shouldConfirm) {
    $confirmation = Read-Host 'Digite LIMPAR para continuar'
    if ($confirmation -cne 'LIMPAR') {
        Write-Host 'Operacao cancelada; nada foi removido.' -ForegroundColor Yellow
        return
    }
}

$provisionedPackages = @(Get-AppxProvisionedPackage -Online)
$removed = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]

foreach ($appName in $apps) {
    if ($protectedApps -contains $appName) {
        $failures.Add("Configuracao invalida: $appName esta protegido.")
        continue
    }

    $changed = $false

    try {
        foreach ($package in @(Get-AppxPackage -Name $appName -AllUsers -ErrorAction SilentlyContinue)) {
            if ($PSCmdlet.ShouldProcess($package.Name, 'Remover aplicativo de todos os usuarios')) {
                Remove-AppxPackage `
                    -Package $package.PackageFullName `
                    -AllUsers `
                    -ErrorAction Stop
                $changed = $true
            }
        }

        foreach ($package in @($provisionedPackages | Where-Object { $_.DisplayName -eq $appName })) {
            if ($PSCmdlet.ShouldProcess($package.DisplayName, 'Remover provisionamento do Windows')) {
                $null = Remove-AppxProvisionedPackage `
                    -Online `
                    -PackageName $package.PackageName `
                    -AllUsers `
                    -ErrorAction Stop
                $changed = $true
            }
        }

        if ($changed) {
            $removed.Add($appName)
            Write-Host "$appName removido." -ForegroundColor Green
        } else {
            Write-Host "$appName nao estava instalado."
        }
    } catch {
        $failures.Add(("{0}: {1}" -f $appName, $_.Exception.Message))
        Write-Host ("Falha ao remover {0}: {1}" -f $appName, $_.Exception.Message) -ForegroundColor Red
    }
}

Write-SetupSection -Message 'Resumo da limpeza'
Write-Host ('Aplicativos removidos: {0}' -f $removed.Count) -ForegroundColor Green

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host "[FALHA] $failure" -ForegroundColor Red
    }
    throw 'A limpeza terminou com uma ou mais falhas.'
}
