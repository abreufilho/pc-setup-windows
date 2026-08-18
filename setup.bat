@echo off
setlocal EnableExtensions

set "SETUP_ROOT=%~dp0"
set "SETUP_LAUNCHER=%~f0"
set "SETUP_ENTRYPOINT=%SETUP_ROOT%setup.ps1"

if not exist "%SETUP_ENTRYPOINT%" (
    echo Arquivo nao encontrado: %SETUP_ENTRYPOINT%
    pause
    exit /b 1
)

rem Solicita elevacao via UAC somente quando necessario.
fltmc >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SETUP_LAUNCHER -WorkingDirectory $env:SETUP_ROOT -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo Nao foi possivel solicitar permissao de administrador.
        pause
        exit /b 1
    )
    exit /b 0
)

pushd "%SETUP_ROOT%" 2>nul
if errorlevel 1 (
    echo Nao foi possivel acessar a pasta: %SETUP_ROOT%
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SETUP_ENTRYPOINT%"
set "SETUP_EXIT_CODE=%ERRORLEVEL%"

if not "%SETUP_EXIT_CODE%"=="0" (
    echo.
    echo O setup terminou com o codigo %SETUP_EXIT_CODE%.
    pause
)

popd
endlocal & exit /b %SETUP_EXIT_CODE%
