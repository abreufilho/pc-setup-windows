[CmdletBinding()]
param(
    [string] $Branch = 'main'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Este bootstrap deve ser executado no Windows.'
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$archiveUri = "https://github.com/abreufilho/pc-setup-windows/archive/refs/heads/$Branch.zip"
$temporaryDirectory = Join-Path $env:TEMP ('pc-setup-{0}' -f [guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $temporaryDirectory 'repository.zip'
$extractPath = Join-Path $temporaryDirectory 'extract'
$destinationPath = Join-Path $env:USERPROFILE 'pc-setup-windows'

try {
    $null = New-Item -Path $temporaryDirectory -ItemType Directory -Force
    Write-Host 'Baixando a versao mais recente do setup...' -ForegroundColor Cyan
    Invoke-WebRequest -Uri $archiveUri -OutFile $archivePath -UseBasicParsing

    if ((Get-Item -LiteralPath $archivePath).Length -lt 1024) {
        throw 'O arquivo baixado e invalido ou esta incompleto.'
    }

    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractPath -Force
    $sourcePath = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    if ($null -eq $sourcePath) {
        throw 'A estrutura esperada nao foi encontrada no arquivo baixado.'
    }

    $null = New-Item -Path $destinationPath -ItemType Directory -Force
    foreach ($item in Get-ChildItem -LiteralPath $sourcePath.FullName -Force) {
        Copy-Item -LiteralPath $item.FullName -Destination $destinationPath -Recurse -Force
    }

    Write-Host "Setup atualizado em: $destinationPath" -ForegroundColor Green

    Start-Process -FilePath (Join-Path $destinationPath 'setup.bat') -WorkingDirectory $destinationPath
} finally {
    if (Test-Path -LiteralPath $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}
