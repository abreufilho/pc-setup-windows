# Windows 11 Taskbar and Widgets Cleanup Script
# Save as taskbar-cleanup.ps1

# Check for administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    Write-Host "Right-click the script and select 'Run with PowerShell as Administrator'" -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit
}

Write-Host "Starting Taskbar and Widgets Cleanup..." -ForegroundColor Cyan

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

# Disable News and Interests
Write-Host "`nDisabling News and Interests..." -ForegroundColor Yellow
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "IsFeedsAvailable" -Value 0

# Disable Widgets
Write-Host "`nDisabling Widgets..." -ForegroundColor Yellow
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0

# Try alternative method for widgets
Write-Host "Attempting alternative method for widgets..." -ForegroundColor Yellow
$WidgetKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if ((Get-ItemProperty -Path $WidgetKey).TaskbarDa -ne 0) {
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
}

# Remove News Related Apps
Write-Host "`nRemoving News Related Apps..." -ForegroundColor Yellow
$NewsApps = @(
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GamingApp"
    "Microsoft.WindowsCommunicationsApps"
)

foreach ($app in $NewsApps) {
    Write-Host "Attempting to remove $app..."
    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction Stop
        Write-Host "$app removed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to remove $app : $_" -ForegroundColor Red
    }
}

# Disable Content Delivery
Write-Host "`nDisabling Content Delivery..." -ForegroundColor Yellow
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$cdmSettings = @(
    "SubscribedContent-338388Enabled"     # News and interests
    "SubscribedContent-338389Enabled"     # Tips and suggestions
    "SubscribedContent-338387Enabled"     # Suggested content
    "SubscribedContent-310093Enabled"     # MS Office ads
)

foreach ($setting in $cdmSettings) {
    Set-RegistryValue -Path $cdmPath -Name $setting -Value 0
}

# Additional taskbar cleanup
Write-Host "`nCleaning up taskbar..." -ForegroundColor Yellow
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

# Force restart Explorer
Write-Host "`nRestarting Explorer to apply changes..." -ForegroundColor Yellow
try {
    taskkill /f /im explorer.exe
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "Explorer restarted successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to restart Explorer: $_" -ForegroundColor Red
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Please restart your computer for all changes to take effect." -ForegroundColor Yellow
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')