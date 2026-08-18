@echo off
setlocal EnableExtensions
title PC Setup Windows 11

set "BOOTSTRAP_URL=https://raw.githubusercontent.com/abreufilho/pc-setup-windows/main/bootstrap.ps1"
set "BOOTSTRAP_PATH=%TEMP%\pc-setup-windows-bootstrap.ps1"
set "WINDOWS_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%WINDOWS_POWERSHELL%" (
    echo Windows PowerShell nao encontrado.
    echo Caminho esperado: %WINDOWS_POWERSHELL%
    pause
    exit /b 1
)

echo Baixando a versao mais recente do instalador...
"%WINDOWS_POWERSHELL%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri $env:BOOTSTRAP_URL -OutFile $env:BOOTSTRAP_PATH"
if errorlevel 1 (
    echo.
    echo Nao foi possivel baixar o instalador. Verifique a conexao com a internet.
    pause
    exit /b 1
)

"%WINDOWS_POWERSHELL%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%BOOTSTRAP_PATH%"
set "INSTALL_EXIT_CODE=%ERRORLEVEL%"

if not "%INSTALL_EXIT_CODE%"=="0" (
    echo.
    echo A instalacao terminou com o codigo %INSTALL_EXIT_CODE%.
    pause
)

endlocal & exit /b %INSTALL_EXIT_CODE%
