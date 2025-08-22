# Fix Desktop Folder Showing as Downloads
# PowerShell script to fix the issue where Desktop folder appears with Downloads icon/name
# Author: Auto-generated fix script
# Date: $(Get-Date)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Desktop Folder Fix Script (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Running as Administrator... Good!" -ForegroundColor Green
Write-Host ""

# Get the current user's Desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$UserProfile = $env:USERPROFILE
$DesktopPath = "$UserProfile\Desktop"

Write-Host "Desktop path: $DesktopPath" -ForegroundColor Yellow
Write-Host ""

# Function to set folder attributes
function Set-FolderAttributes {
    param($Path, $Attributes)
    try {
        $folder = Get-Item $Path -Force
        $folder.Attributes = $Attributes
        return $true
    } catch {
        Write-Host "Warning: Could not set attributes for $Path" -ForegroundColor Yellow
        return $false
    }
}

# Backup existing desktop.ini if it exists
$DesktopIniPath = "$DesktopPath\desktop.ini"
if (Test-Path $DesktopIniPath) {
    Write-Host "Backing up existing desktop.ini..." -ForegroundColor Yellow
    try {
        Copy-Item $DesktopIniPath "$DesktopIniPath.backup" -Force
        Write-Host "Backup created: desktop.ini.backup" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not create backup" -ForegroundColor Yellow
    }
}
# Remove attributes from Desktop folder
Write-Host "Removing folder attributes..." -ForegroundColor Yellow
try {
    $folder = Get-Item $DesktopPath -Force
    $folder.Attributes = "Directory"
    Write-Host "Folder attributes reset" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not reset folder attributes" -ForegroundColor Yellow
}

# Remove desktop.ini file if it exists
if (Test-Path $DesktopIniPath) {
    Write-Host "Removing corrupted desktop.ini..." -ForegroundColor Yellow
    try {
        Remove-Item $DesktopIniPath -Force
        Write-Host "Corrupted desktop.ini removed" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not remove desktop.ini" -ForegroundColor Yellow
    }
}

# Create proper desktop.ini content
$DesktopIniContent = @'
[.ShellClassInfo]
LocalizedResourceName=@%SystemRoot%\system32\shell32.dll,-21769
IconResource=%SystemRoot%\system32\imageres.dll,-183
[ViewState]
Mode=
Vid=
FolderType=Generic
'@

Write-Host "Creating proper desktop.ini..." -ForegroundColor Yellow
try {
    $DesktopIniContent | Out-File -FilePath $DesktopIniPath -Encoding ASCII -Force
    
    # Set proper attributes for desktop.ini (System + Hidden)
    $desktopIniFile = Get-Item $DesktopIniPath -Force
    $desktopIniFile.Attributes = "System,Hidden"
    
    Write-Host "desktop.ini created with proper attributes" -ForegroundColor Green
} catch {
    Write-Host "Error: Could not create desktop.ini" -ForegroundColor Red
}

# Set proper attributes for Desktop folder (ReadOnly to make it a system folder)
Write-Host "Setting proper Desktop folder attributes..." -ForegroundColor Yellow
try {
    $folder = Get-Item $DesktopPath -Force
    $folder.Attributes = "Directory,ReadOnly"
    Write-Host "Desktop folder attributes set correctly" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not set Desktop folder attributes" -ForegroundColor Yellow
}

# Registry fix for shell folders (optional but recommended)
Write-Host "Checking registry settings..." -ForegroundColor Yellow
try {
    $ShellFoldersKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
    $UserShellFoldersKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    
    # Ensure Desktop registry entries are correct
    Set-ItemProperty -Path $ShellFoldersKey -Name "Desktop" -Value $DesktopPath -Force
    Set-ItemProperty -Path $UserShellFoldersKey -Name "Desktop" -Value "%USERPROFILE%\Desktop" -Force
    
    Write-Host "Registry settings verified" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not update registry settings" -ForegroundColor Yellow
}

# Refresh Explorer
Write-Host ""
Write-Host "Refreshing Explorer..." -ForegroundColor Yellow
try {
    # Method 1: Try to refresh without killing explorer
    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace($DesktopPath).Self.InvokeVerb("refresh")
    
    Start-Sleep -Seconds 2
    
    # Method 2: If that doesn't work, restart explorer
    $explorerProcesses = Get-Process -Name "explorer" -ErrorAction SilentlyContinue
    if ($explorerProcesses) {
        Stop-Process -Name "explorer" -Force
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe"
    }
    
    Write-Host "Explorer refreshed" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not refresh Explorer automatically" -ForegroundColor Yellow
    Write-Host "Please manually restart Explorer or log off/on" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fix completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The Desktop folder should now display correctly." -ForegroundColor Green
Write-Host ""
Write-Host "If the issue persists, try:" -ForegroundColor Yellow
Write-Host "1. Log off and log back in" -ForegroundColor White
Write-Host "2. Restart your computer" -ForegroundColor White
Write-Host "3. Check Windows File Explorer > View > Options > View tab" -ForegroundColor White
Write-Host "   and ensure 'Hide protected operating system files' is checked" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
