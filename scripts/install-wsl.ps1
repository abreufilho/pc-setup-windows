# WSL2 Installation and Setup Script
# Save as install-wsl.ps1
# Run as administrator

Write-Host "Starting WSL2 Installation..." -ForegroundColor Cyan

# Check Windows version (needs Windows 10 version 2004 or higher)
$windowsVersion = [System.Environment]::OSVersion.Version
if ($windowsVersion.Build -lt 19041) {
    Write-Host "Error: You need Windows 10 version 2004 or higher to install WSL2" -ForegroundColor Red
    exit 1
}

# Enable Windows features
Write-Host "`nEnabling required Windows features..." -ForegroundColor Yellow
try {
    # Enable Virtual Machine Platform
    Write-Host "Enabling Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # Enable WSL
    Write-Host "Enabling Windows Subsystem for Linux..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
} catch {
    Write-Host "Error enabling Windows features: $_" -ForegroundColor Red
    exit 1
}

# Install WSL command
Write-Host "`nInstalling WSL..." -ForegroundColor Yellow
try {
    wsl --install --no-distribution
} catch {
    Write-Host "Error installing WSL: $_" -ForegroundColor Red
    exit 1
}

# Set WSL 2 as default
Write-Host "`nSetting WSL 2 as default..." -ForegroundColor Yellow
try {
    wsl --set-default-version 2
} catch {
    Write-Host "Error setting WSL 2 as default: $_" -ForegroundColor Red
}

# Install Ubuntu (default distribution)
Write-Host "`nInstalling Ubuntu..." -ForegroundColor Yellow
try {
    wsl --install -d Ubuntu
} catch {
    Write-Host "Error installing Ubuntu: $_" -ForegroundColor Red
}

Write-Host "`nWSL2 installation complete!" -ForegroundColor Green
Write-Host "IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Restart your computer now" -ForegroundColor Yellow
Write-Host "2. After restart, Ubuntu will automatically start and ask you to create a username and password" -ForegroundColor Yellow
Write-Host "3. After that's done, you can proceed with installing Docker Desktop" -ForegroundColor Yellow

Write-Host "`nWould you like to restart your computer now? (y/n)" -ForegroundColor Cyan
$response = Read-Host
if ($response -eq 'y') {
    Restart-Computer -Force
} else {
    Write-Host "`nPlease restart your computer manually before using WSL2" -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}