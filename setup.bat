@echo off
setlocal EnableExtensions

set "SETUP_ROOT=%~dp0"
set "SETUP_LAUNCHER=%~f0"

rem Solicita elevacao via UAC quando o launcher nao esta como administrador.
fltmc >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SETUP_LAUNCHER -WorkingDirectory $env:SETUP_ROOT -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo Nao foi possivel solicitar permissao de administrador.
        pause
    )
    exit /b
)

pushd "%SETUP_ROOT%" 2>nul
if errorlevel 1 (
    echo Nao foi possivel acessar a pasta do setup: %SETUP_ROOT%
    pause
    exit /b 1
)

echo Desbloqueando os arquivos baixados...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath $env:SETUP_ROOT -Recurse -File | Unblock-File -ErrorAction Stop"
if errorlevel 1 (
    echo.
    echo Falha ao desbloquear os arquivos do setup.
    pause
    popd
    exit /b 1
)

:menu
cls
echo ============================================================
echo              CONFIGURACAO DO WINDOWS 11
echo ============================================================
echo.
echo Os arquivos estao desbloqueados e este menu esta como Admin.
echo.
echo  1 - Instalar programas
echo  2 - Instalar e configurar WSL2
echo  3 - Aplicar personalizacoes visuais
echo  4 - Otimizar desempenho
echo  5 - Aplicar configuracoes de privacidade
echo  6 - Remover aplicativos e servicos ^(debloat^)
echo  7 - Limpar barra de tarefas e widgets
echo  8 - Definir avatar do usuario
echo  9 - Abrir PowerShell preparado nesta pasta
echo  0 - Sair
echo.
choice /C 1234567890 /N /M "Escolha uma opcao: "
set "SETUP_OPTION=%ERRORLEVEL%"

if "%SETUP_OPTION%"=="1" call :run_script "install-programs.ps1"
if "%SETUP_OPTION%"=="2" call :run_script "install-wsl.ps1"
if "%SETUP_OPTION%"=="3" call :run_script "customization-screen.ps1"
if "%SETUP_OPTION%"=="4" call :run_script "performance-optimize.ps1"
if "%SETUP_OPTION%"=="5" call :run_script "privacy-enhancement.ps1"
if "%SETUP_OPTION%"=="6" call :run_script "debloat.ps1"
if "%SETUP_OPTION%"=="7" call :run_script "taskbar-cleanup.ps1"
if "%SETUP_OPTION%"=="8" call :run_script "user-avatar.ps1"
if "%SETUP_OPTION%"=="9" call :open_powershell
if "%SETUP_OPTION%"=="10" goto :finish

goto :menu

:run_script
set "SETUP_SCRIPT=%~1"
set "SETUP_SCRIPT_PATH=%SETUP_ROOT%scripts\%SETUP_SCRIPT%"

if not exist "%SETUP_SCRIPT_PATH%" (
    echo.
    echo Script nao encontrado: %SETUP_SCRIPT_PATH%
    pause
    exit /b 1
)

cls
echo Executando scripts\%SETUP_SCRIPT% como administrador...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SETUP_SCRIPT_PATH%"
set "SETUP_EXIT_CODE=%ERRORLEVEL%"

if not "%SETUP_EXIT_CODE%"=="0" (
    echo.
    echo O script terminou com o codigo %SETUP_EXIT_CODE%.
    pause
)
exit /b

:open_powershell
start "PowerShell Admin - PC Setup" powershell.exe -NoLogo -NoExit -NoProfile -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath $env:SETUP_ROOT; Write-Host 'PowerShell preparado. Scripts disponiveis em .\scripts' -ForegroundColor Green"
exit /b

:finish
popd
endlocal
exit /b 0
