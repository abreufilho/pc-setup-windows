Set-StrictMode -Version 2.0

function Test-SetupAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-SetupEnvironment {
    param(
        [switch] $RequireAdministrator
    )

    if ($env:OS -ne 'Windows_NT') {
        throw 'Este setup deve ser executado no Windows.'
    }

    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw 'Windows PowerShell 5.1 ou superior e necessario.'
    }

    if ($RequireAdministrator -and -not (Test-SetupAdministrator)) {
        throw 'Execute este comando em uma sessao elevada como Administrador.'
    }
}

function Write-SetupSection {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    Write-Host ''
    Write-Host ('== {0} ==' -f $Message) -ForegroundColor Cyan
}

function Set-SetupRegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Value,

        [ValidateSet('String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'QWord')]
        [string] $Type = 'DWord'
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        $null = New-Item -Path $Path -Force
    }

    $null = New-ItemProperty `
        -Path $Path `
        -Name $Name `
        -Value $Value `
        -PropertyType $Type `
        -Force `
        -ErrorAction Stop
}

function Invoke-SetupNativeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string] $FilePath,

        [string[]] $ArgumentList = @(),

        [int[]] $SuccessExitCodes = @(0)
    )

    $command = Get-Command $FilePath -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Comando nao encontrado: $FilePath"
    }

    & $command.Source @ArgumentList
    $exitCode = $LASTEXITCODE

    if ($SuccessExitCodes -notcontains $exitCode) {
        throw "O comando '$FilePath' terminou com o codigo $exitCode."
    }
}

function Test-SetupPendingRestart {
    $rebootKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )

    foreach ($key in $rebootKeys) {
        if (Test-Path -LiteralPath $key) {
            return $true
        }
    }

    $sessionManager = Get-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
        -Name 'PendingFileRenameOperations' `
        -ErrorAction SilentlyContinue

    return $null -ne $sessionManager
}

function Restart-SetupExplorer {
    Write-Host 'Reiniciando o Explorer para aplicar as alteracoes...' -ForegroundColor Yellow

    Get-Process -Name explorer -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
}

Export-ModuleMember -Function @(
    'Assert-SetupEnvironment'
    'Invoke-SetupNativeCommand'
    'Restart-SetupExplorer'
    'Set-SetupRegistryValue'
    'Test-SetupAdministrator'
    'Test-SetupPendingRestart'
    'Write-SetupSection'
)

