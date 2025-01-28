# Programs Installation Script
# Save as install-programs.ps1
# Run as administrator

Write-Host "Installing programs..." -ForegroundColor Cyan

# Regular applications
$apps = @(
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "KeePassXCTeam.KeePassXC",
    "Google.GoogleDrive",
    "Google.Chrome",
    "Discord.Discord",
    "Docker.DockerDesktop",
    "Obsidian.Obsidian",
    "dbeaver.dbeaver"
)

# Microsoft Store applications
$msApps = @(
    "9NKSQGP7F2NH"  # WhatsApp
)

# Install regular applications
foreach ($app in $apps) {
    Write-Host "`nInstalling $app..." -ForegroundColor Yellow
    winget install --id $app --accept-source-agreements --accept-package-agreements --silent
}

# Install Microsoft Store applications
foreach ($app in $msApps) {
    Write-Host "`nInstalling Microsoft Store app: $app..." -ForegroundColor Yellow
    winget install --id $app --source msstore --accept-source-agreements --accept-package-agreements --silent
}

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')