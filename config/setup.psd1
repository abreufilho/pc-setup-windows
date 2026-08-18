@{
    General = @{
        AvatarUri      = 'https://avatars.githubusercontent.com/u/110954696'
        WslDistribution = 'Ubuntu'
        PowerPlan       = 'Balanced'
    }

    RemoteAccess = @{
        PublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcgD48mQkkgfoiQ9CBdiyrR6RlHvzwID66eD9Tg/+rH pc-setup-windows'
    }

    Programs = @(
        @{ Id = 'Git.Git';                         Name = 'Git';             Source = 'winget'; Group = 'Core' }
        @{ Id = 'Microsoft.VisualStudioCode';      Name = 'Visual Studio Code'; Source = 'winget'; Group = 'Core' }
        @{ Id = 'KeePassXCTeam.KeePassXC';         Name = 'KeePassXC';       Source = 'winget'; Group = 'Core' }
        @{ Id = 'Google.Chrome';                   Name = 'Google Chrome';   Source = 'winget'; Group = 'Core' }
        @{ Id = 'Docker.DockerDesktop';            Name = 'Docker Desktop'; Source = 'winget'; Group = 'Development' }
        @{ Id = 'DBeaver.DBeaver';                 Name = 'DBeaver';         Source = 'winget'; Group = 'Development' }
        @{ Id = 'Obsidian.Obsidian';               Name = 'Obsidian';       Source = 'winget'; Group = 'Personal' }
        @{ Id = 'Google.GoogleDrive';              Name = 'Google Drive';   Source = 'winget'; Group = 'Personal' }
        @{ Id = 'Discord.Discord';                 Name = 'Discord';        Source = 'winget'; Group = 'Personal' }
        @{ Id = '9NKSQGP7F2NH';                    Name = 'WhatsApp';        Source = 'msstore'; Group = 'Personal' }
    )

    Cleanup = @{
        Mode                = 'Aggressive'
        RequireConfirmation = $false
        Apps                = @(
            'Clipchamp.Clipchamp'
            'Microsoft.BingNews'
            'Microsoft.BingSearch'
            'Microsoft.BingWeather'
            'Microsoft.Copilot'
            'Microsoft.GamingApp'
            'Microsoft.GetHelp'
            'Microsoft.Getstarted'
            'Microsoft.MicrosoftOfficeHub'
            'Microsoft.MicrosoftSolitaireCollection'
            'Microsoft.MicrosoftStickyNotes'
            'Microsoft.OutlookForWindows'
            'Microsoft.People'
            'Microsoft.PowerAutomateDesktop'
            'Microsoft.Todos'
            'Microsoft.Whiteboard'
            'Microsoft.Windows.DevHome'
            'Microsoft.WindowsAlarms'
            'Microsoft.WindowsFeedbackHub'
            'Microsoft.WindowsMaps'
            'Microsoft.WindowsSoundRecorder'
            'Microsoft.Xbox.TCUI'
            'Microsoft.XboxGamingOverlay'
            'Microsoft.XboxIdentityProvider'
            'Microsoft.XboxSpeechToTextOverlay'
            'Microsoft.YourPhone'
            'Microsoft.ZuneMusic'
            'Microsoft.549981C3F5F10'
            'MicrosoftCorporationII.QuickAssist'
            'MicrosoftTeams'
            'MicrosoftWindows.CrossDevice'
            'MSTeams'
            'microsoft.windowscommunicationsapps'
        )
        ProtectedApps       = @(
            'Microsoft.SecHealthUI'
            'Microsoft.WindowsStore'
            'Microsoft.DesktopAppInstaller'
            'Microsoft.StartExperiencesApp'
            'Microsoft.WindowsCalculator'
            'Microsoft.WindowsNotepad'
            'Microsoft.Windows.Photos'
            'Microsoft.Paint'
            'Microsoft.ScreenSketch'
            'Microsoft.WindowsCamera'
        )
    }

    RecommendedScripts = @(
        'enable-ssh.ps1'
        'create-restore-point.ps1'
        'remove-onedrive.ps1'
        'debloat.ps1'
        'install-programs.ps1'
        'install-wsl.ps1'
        'customization-screen.ps1'
        'performance-optimize.ps1'
        'privacy-enhancement.ps1'
        'taskbar-cleanup.ps1'
        'user-avatar.ps1'
    )
}
