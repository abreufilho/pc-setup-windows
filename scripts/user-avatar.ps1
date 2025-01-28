# Download and Set GitHub Avatar Script
# Save as github-avatar.ps1
# Run as administrator

Write-Host "Downloading and Setting GitHub Avatar..." -ForegroundColor Cyan

# Download the image
try {
    $downloadPath = "$env:TEMP\github-avatar.png"
    Write-Host "Downloading avatar..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://avatars.githubusercontent.com/u/110954696" -OutFile $downloadPath
    Write-Host "Avatar downloaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error downloading avatar: $_" -ForegroundColor Red
    exit
}

# Set the avatar
try {
    # Get current user's SID
    $UserSID = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value

    # Set up paths
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\$UserSID"
    $DestFolder = "$env:PUBLIC\AccountPictures"

    # Create necessary directories
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    if (-not (Test-Path $DestFolder)) {
        New-Item -Path $DestFolder -ItemType Directory -Force | Out-Null
    }

    # Copy image to Windows account pictures folder
    $NewImagePath = "$DestFolder\$($env:USERNAME).png"
    Copy-Item -Path $downloadPath -Destination $NewImagePath -Force

    # Set registry values for different image sizes
    $sizes = @(32, 40, 48, 96, 192, 240, 448)
    foreach ($size in $sizes) {
        Set-ItemProperty -Path $RegPath -Name "Image$size" -Value $NewImagePath -ErrorAction SilentlyContinue
    }

    Write-Host "`nAvatar set successfully!" -ForegroundColor Green
    Write-Host "Please sign out and sign back in to see the changes." -ForegroundColor Yellow
}
catch {
    Write-Host "Error setting avatar: $_" -ForegroundColor Red
}
finally {
    # Cleanup downloaded file
    if (Test-Path $downloadPath) {
        Remove-Item -Path $downloadPath -Force
    }
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')