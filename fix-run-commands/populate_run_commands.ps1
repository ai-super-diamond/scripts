# ============================================================================
# Win+R Command History Populator
# ============================================================================
# This script populates your Windows Run dialog (Win+R) with frequently used commands
# so they're always available in autocomplete/history, even after system cleaners or resets.
#
# USAGE: 
# 1. Edit the $Commands array below to add your favorite commands
# 2. Run this script as Administrator after login or Windows reinstall
# 3. Your commands will appear in Win+R history immediately
#
# TIP: Add this to Windows startup or run it whenever you want to refresh your command list
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Win+R Command History Populator" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# EDIT THIS SECTION - ADD YOUR FAVORITE COMMANDS HERE
# ============================================================================
# Simply add or remove commands from this list. Keep the quotes and commas.
# The script will automatically add them to your Win+R history.

$Commands = @(
    # System Commands
    "cmd",
    "powershell",
    "regedit",
    "msconfig",
    "services.msc",
    "devmgmt.msc",
    "diskmgmt.msc",
    "eventvwr.msc",
    "perfmon.msc",
    "taskschd.msc",
    
    # Control Panel & Settings
    "control",
    "appwiz.cpl",
    "desk.cpl",
    "firewall.cpl",
    "main.cpl",
    "ncpa.cpl",
    "powercfg.cpl",
    "sysdm.cpl",
    "timedate.cpl",
    
    # System Tools
    "calc",
    "notepad",
    "mspaint",
    "charmap",
    "winver",
    "dxdiag",
    "msinfo32",
    "cleanmgr",
    "defrag",
    "chkdsk"    
    # Network & Internet
    "ipconfig",
    "ping google.com",
    "nslookup",
    "netstat -an",
    "arp -a",
    "tracert google.com",
    "netsh wlan show profiles",
    
    # Development Tools (add your own paths)
    "code",                    # VS Code (if in PATH)
    "git",                     # Git (if in PATH) 
    "node",                    # Node.js (if in PATH)
    "python",                  # Python (if in PATH)
    
    # Custom Paths (EDIT THESE TO YOUR ACTUAL PATHS)
    # "C:\Program Files\Notepad++\notepad++.exe",
    # "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    # "C:\java\utils\myUtils",
    # "D:\Projects",
    
    # Quick Navigation
    ".",                       # Current folder
    "..",                      # Parent folder  
    "explorer",               # File Explorer
    "shell:startup",          # Startup folder
    "shell:desktop",          # Desktop folder
    "shell:downloads",        # Downloads folder
    "shell:documents",        # Documents folder
    "temp",                   # Temp folder
    "%appdata%",              # AppData folder
    "%programfiles%",         # Program Files
    
    # System Utilities
    "taskmgr",                # Task Manager
    "resmon",                 # Resource Monitor
    "mstsc",                  # Remote Desktop
    "snippingtool",           # Snipping Tool
    "osk",                    # On-Screen Keyboard
    "magnify"                 # Magnifier
)

# ============================================================================
# ADVANCED COMMANDS SECTION (Optional)
# ============================================================================
# Uncomment and add more specialized commands here:

<#
$AdvancedCommands = @(
    # PowerShell Commands
    "powershell -noexit -command Get-Process",
    "powershell -noexit -command Get-Service", 
    "powershell -command Get-ComputerInfo",
    
    # Network Diagnostics
    "cmd /k ipconfig /all",
    "cmd /k netstat -an | more",
    "cmd /k systeminfo",
    
    # Your Custom Scripts
    "powershell -file C:\your\script\path.ps1"
)
# Add advanced commands to main list
$Commands += $AdvancedCommands
#>

# ============================================================================
# SCRIPT LOGIC - Don't edit below unless you know what you're doing
# ============================================================================

Write-Host "Starting Win+R command population..." -ForegroundColor Yellow
Write-Host "Commands to add: $($Commands.Count)" -ForegroundColor Cyan
Write-Host ""

# Registry path for Run MRU (Most Recently Used)
$RunMRUPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"

try {
    # Ensure the registry path exists
    if (!(Test-Path $RunMRUPath)) {
        Write-Host "Creating RunMRU registry path..." -ForegroundColor Yellow
        New-Item -Path $RunMRUPath -Force | Out-Null
    }

    # Get existing registry values to preserve user's current commands
    Write-Host "Reading existing Run history..." -ForegroundColor Yellow
    $existingValues = @()
    try {
        $existingKeys = Get-ItemProperty -Path $RunMRUPath -ErrorAction SilentlyContinue
        if ($existingKeys) {
            # Get all lettered properties (a, b, c, etc.) and extract commands
            $existingKeys.PSObject.Properties | Where-Object { 
                $_.Name -match '^[a-z]$' -and $_.Value -ne $null 
            } | ForEach-Object {
                $command = $_.Value -replace '\\1$', ''  # Remove \1 suffix
                if ($command -and $command.Trim()) {
                    $existingValues += $command.Trim()
                }
            }
        }
    } catch {
        Write-Host "No existing Run history found (this is normal for new installations)" -ForegroundColor Green
    }

    # Combine existing commands with our new ones, removing duplicates
    # Put our commands first so they appear at the top of Win+R autocomplete
    $allCommands = @()
    $allCommands += $Commands
    
    # Add existing commands that aren't already in our list
    foreach ($existing in $existingValues) {
        if ($existing -notin $Commands) {
            $allCommands += $existing
        }
    }

    # Remove duplicates and limit to reasonable number (Windows typically shows ~20-30)
    $allCommands = $allCommands | Select-Object -Unique | Select-Object -First 26  # a-z = 26 letters max

    Write-Host "Total commands after merge: $($allCommands.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    # Clear existing RunMRU entries to start fresh
    Write-Host "Clearing old Run history..." -ForegroundColor Yellow
    $existingItems = Get-ItemProperty -Path $RunMRUPath -ErrorAction SilentlyContinue
    if ($existingItems) {
        $existingItems.PSObject.Properties | Where-Object { 
            $_.Name -match '^[a-z]$|^MRUList$' 
        } | ForEach-Object {
            Remove-ItemProperty -Path $RunMRUPath -Name $_.Name -ErrorAction SilentlyContinue
        }
    }

    # Write new commands to registry
    Write-Host "Adding commands to Run history..." -ForegroundColor Yellow
    $letters = [char[]]([char]'a'..[char]'z')  # a, b, c, d, ... z
    $mruList = ""
    
    for ($i = 0; $i -lt $allCommands.Count -and $i -lt 26; $i++) {
        $letter = $letters[$i]
        $command = $allCommands[$i]
        $registryValue = "$command\1"  # Windows adds \1 suffix to Run commands
        
        # Write command to registry
        Set-ItemProperty -Path $RunMRUPath -Name $letter -Value $registryValue -Type String
        $mruList += $letter
        
        Write-Host "  [$letter] $command" -ForegroundColor Green
    }
    
    # Set MRUList (this determines the order in Win+R dropdown)
    Set-ItemProperty -Path $RunMRUPath -Name "MRUList" -Value $mruList -Type String
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS! Run commands populated!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Added $($allCommands.Count) commands to Win+R history" -ForegroundColor Green
    Write-Host "✅ Commands are ready to use immediately" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 TIP: Press Win+R and start typing to see your commands!" -ForegroundColor Yellow
    Write-Host "💡 TIP: Run this script after system cleaners or Windows resets" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "❌ ERROR: Could not populate Run commands" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure no other programs are accessing the registry" -ForegroundColor White
    Write-Host "2. Try running as Administrator if the error persists" -ForegroundColor White
    Write-Host "3. Check if your antivirus is blocking registry access" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
