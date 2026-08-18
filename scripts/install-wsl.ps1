[CmdletBinding()]
param(
    [string] $Distribution,
    [switch] $WebDownload
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptsPath
Import-Module (Join-Path $scriptsPath 'lib\Setup.Common.psm1') -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path (Join-Path $rootPath 'config\setup.psd1')
if ([string]::IsNullOrWhiteSpace($Distribution)) {
    $Distribution = $config.General.WslDistribution
}

$buildNumber = [Environment]::OSVersion.Version.Build
if ($buildNumber -lt 19041) {
    throw "O WSL 2 exige Windows build 19041 ou superior. Build atual: $buildNumber."
}

Write-SetupSection -Message 'Verificando WSL 2'
$installedDistributions = @()
$distributionOutput = & wsl.exe --list --quiet 2>$null

if ($LASTEXITCODE -eq 0) {
    $installedDistributions = @(
        $distributionOutput |
            ForEach-Object { ($_ -replace "`0", '').Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}

if ($installedDistributions -contains $Distribution) {
    Write-Host "$Distribution ja esta instalado." -ForegroundColor Green
    Invoke-SetupNativeCommand -FilePath 'wsl.exe' -ArgumentList @('--set-default-version', '2')

    try {
        Invoke-SetupNativeCommand -FilePath 'wsl.exe' -ArgumentList @('--update')
    } catch {
        Write-Warning "Nao foi possivel atualizar o WSL agora: $($_.Exception.Message)"
    }
} else {
    Write-Host "Instalando WSL 2 com $Distribution..." -ForegroundColor Yellow
    $installArguments = @('--install', '--distribution', $Distribution, '--no-launch')
    if ($WebDownload) {
        $installArguments += '--web-download'
    }

    Invoke-SetupNativeCommand `
        -FilePath 'wsl.exe' `
        -ArgumentList $installArguments `
        -SuccessExitCodes @(0, 3010)

    try {
        Invoke-SetupNativeCommand -FilePath 'wsl.exe' -ArgumentList @('--set-default-version', '2')
    } catch {
        Write-Warning 'A versao padrao sera confirmada depois da reinicializacao.'
    }
}

Write-SetupSection -Message 'Estado do WSL'
& wsl.exe --status

if (Test-SetupPendingRestart) {
    Write-Host 'Reinicie o Windows antes de abrir o Ubuntu ou iniciar o Docker Desktop.' -ForegroundColor Yellow
} else {
    Write-Host "Abra $Distribution para concluir a criacao do usuario Linux." -ForegroundColor Green
}
