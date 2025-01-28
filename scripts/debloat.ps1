# Requires administrator privileges
# Right-click this script and select "Run as Administrator"

# Stop and disable unnecessary services
$ServicesToDisable = @(
    "DiagTrack"                # Connected User Experiences and Telemetry
    "dmwappushservice"         # Device Management Wireless Application Protocol
    "SysMain"                  # Superfetch
    "OneSyncSvc"              # Sync Host Service
    "RetailDemo"              # Retail Demo Service
)

foreach ($service in $ServicesToDisable) {
    Write-Host "Stopping and disabling $service..."
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# Remove built-in apps
$AppsToRemove = @(
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GamingApp"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.SecHealthUI"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsAlarms"
    "Microsoft.YourPhone"
    "MicrosoftTeams"
    "Microsoft.549981C3F5F10"  # Cortana
)

foreach ($app in $AppsToRemove) {
    Write-Host "Removing $app..."
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Disable Windows telemetry
Write-Host "Disabling telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0

# Disable Cortana
Write-Host "Disabling Cortana..."
If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
    New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0

# Disable Tips and Suggestions
Write-Host "Disabling Windows Tips and Suggestions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0

# Disable background apps
Write-Host "Disabling background apps..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1

# Optional: Disable Windows Search indexing
Write-Host "Disabling Windows Search indexing..."
Stop-Service "WSearch" -Force
Set-Service "WSearch" -StartupType Disabled

Write-Host "Cleanup complete! Please restart your computer for changes to take effect."

# Note: Some of these changes may reset after major Windows updates