# Windows 11 Visual Customization Script
# Save as visual-customize.ps1
# Run as administrator

Write-Host "Applying Visual Customizations..." -ForegroundColor Cyan

# Function to safely set registry values
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value
    )
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        Write-Host "Successfully set $Name" -ForegroundColor Green
    } catch {
        Write-Host "Failed to set $Name : $_" -ForegroundColor Red
    }
}

# Set display scaling to 100%
Write-Host "`nSetting display scaling to 100%..." -ForegroundColor Yellow
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -Value 120
Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" -Name "Win8DpiScaling" -Value 1

# Set solid color as background
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value ""
Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "50 50 50"

# Refresh the desktop
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Move taskbar to the left
Write-Host "`nMoving taskbar alignment to left..." -ForegroundColor Yellow
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0

# Enable Dark Mode
Write-Host "`nEnabling Dark Mode..." -ForegroundColor Yellow
# System-wide dark mode
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
# Apps dark mode
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0

# Additional taskbar settings
Write-Host "`nCustomizing taskbar settings..." -ForegroundColor Yellow
# Show all taskbar icons
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 0
# Combine taskbar buttons when taskbar is full
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value 0
# Make sure small taskbar buttons are enabled
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 1
# Show taskbar on all displays
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Value 1

# Force restart Explorer to apply changes
Write-Host "`nRestarting Explorer to apply changes..." -ForegroundColor Yellow
try {
    taskkill /f /im explorer.exe
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "Explorer restarted successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to restart Explorer: $_" -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')