[CmdletBinding()]
param(
    [ValidateSet('Menu', 'Recommended')]
    [string] $Preset = 'Menu'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $rootPath 'scripts\lib\Setup.Common.psm1'
$configPath = Join-Path $rootPath 'config\setup.psd1'

Import-Module $modulePath -Force
Assert-SetupEnvironment -RequireAdministrator

$config = Import-PowerShellDataFile -Path $configPath
$logDirectory = Join-Path $rootPath 'logs'
$null = New-Item -Path $logDirectory -ItemType Directory -Force
$logPath = Join-Path $logDirectory ('setup-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$transcriptStarted = $false

try {
    Start-Transcript -Path $logPath -Force | Out-Null
    $transcriptStarted = $true
} catch {
    Write-Warning "Nao foi possivel iniciar o log: $($_.Exception.Message)"
}

Get-ChildItem -LiteralPath $rootPath -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

$actions = [ordered]@{
    '1' = @{ Label = 'Executar configuracao recomendada'; Script = $null }
    '2' = @{ Label = 'Instalar programas'; Script = 'install-programs.ps1' }
    '3' = @{ Label = 'Instalar ou atualizar WSL 2'; Script = 'install-wsl.ps1' }
    '4' = @{ Label = 'Habilitar acesso SSH na rede local'; Script = 'enable-ssh.ps1' }
    '5' = @{ Label = 'Aplicar personalizacao visual'; Script = 'customization-screen.ps1' }
    '6' = @{ Label = 'Aplicar ajustes conservadores de desempenho'; Script = 'performance-optimize.ps1' }
    '7' = @{ Label = 'Aplicar ajustes de privacidade'; Script = 'privacy-enhancement.ps1' }
    '8' = @{ Label = 'Limpar barra de tarefas'; Script = 'taskbar-cleanup.ps1' }
    '9' = @{ Label = 'Executar limpeza agressiva pos-formatacao'; Script = 'debloat.ps1' }
    'A' = @{ Label = 'Definir avatar do usuario'; Script = 'user-avatar.ps1' }
    'B' = @{ Label = 'Desativar e desinstalar OneDrive'; Script = 'remove-onedrive.ps1' }
    'C' = @{ Label = 'Criar ponto de restauracao'; Script = 'create-restore-point.ps1' }
}

function Invoke-RepositoryScript {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ScriptName
    )

    $scriptPath = Join-Path $rootPath ('scripts\{0}' -f $ScriptName)
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw "Script nao encontrado: $scriptPath"
    }

    Write-SetupSection -Message $ScriptName
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $scriptPath
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "O script $ScriptName terminou com o codigo $exitCode."
    }
}

function Invoke-RecommendedSetup {
    $failures = New-Object System.Collections.Generic.List[string]

    foreach ($scriptName in $config.RecommendedScripts) {
        try {
            Invoke-RepositoryScript -ScriptName $scriptName
        } catch {
            $failures.Add(('{0}: {1}' -f $scriptName, $_.Exception.Message))
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }

    Write-SetupSection -Message 'Resumo da configuracao recomendada'
    if ($failures.Count -gt 0) {
        foreach ($failure in $failures) {
            Write-Host "[FALHA] $failure" -ForegroundColor Red
        }
        throw 'Uma ou mais etapas falharam. Corrija os itens acima e execute novamente.'
    }

    Write-Host 'Todas as etapas recomendadas terminaram com sucesso.' -ForegroundColor Green
}

function Show-SetupMenu {
    while ($true) {
        Clear-Host
        Write-Host '============================================================'
        Write-Host '              CONFIGURACAO DO WINDOWS 11'
        Write-Host '============================================================'
        Write-Host ''
        Write-Host 'Scripts idempotentes; podem ser executados novamente.'
        Write-Host "Log desta sessao: $logPath"
        Write-Host ''

        foreach ($key in $actions.Keys) {
            Write-Host (' {0} - {1}' -f $key, $actions[$key].Label)
        }

        Write-Host ' 0 - Sair'
        Write-Host ''
        $selection = (Read-Host 'Escolha uma opcao').ToUpperInvariant()

        if ($selection -eq '0') {
            return
        }

        if (-not $actions.Contains($selection)) {
            Write-Host 'Opcao invalida.' -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            continue
        }

        try {
            if ($selection -eq '1') {
                Invoke-RecommendedSetup
            } else {
                Invoke-RepositoryScript -ScriptName $actions[$selection].Script
            }
        } catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }

        if (Test-SetupPendingRestart) {
            Write-Host ''
            Write-Host 'O Windows informa que ha uma reinicializacao pendente.' -ForegroundColor Yellow
        }

        Write-Host ''
        $null = Read-Host 'Pressione Enter para voltar ao menu'
    }
}

try {
    if ($Preset -eq 'Recommended') {
        Invoke-RecommendedSetup
    } else {
        Show-SetupMenu
    }
} finally {
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}
