# ============================================================================
# Win+R Command History Populator (File-Based Version)
# ============================================================================
# This version reads commands from "run_commands.txt" file
# Much easier to edit - just modify the text file and run this script!
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Win+R Command Populator (File-Based)" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory and config file path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "run_commands.txt"

# Check if config file exists
if (!(Test-Path $ConfigFile)) {
    Write-Host "❌ ERROR: Config file not found!" -ForegroundColor Red
    Write-Host "Expected: $ConfigFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please make sure 'run_commands.txt' is in the same folder as this script." -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Read commands from file
Write-Host "📖 Reading commands from: run_commands.txt" -ForegroundColor Yellow
try {
    $Commands = @()
    $fileContent = Get-Content $ConfigFile -ErrorAction Stop
    
    foreach ($line in $fileContent) {
        $line = $line.Trim()
        # Skip empty lines and comments
        if ($line -and !$line.StartsWith('#')) {
            $Commands += $line
        }
    }
    
    if ($Commands.Count -eq 0) {
        Write-Host "⚠️  WARNING: No commands found in config file!" -ForegroundColor Yellow
        Write-Host "Please add some commands to run_commands.txt" -ForegroundColor White
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "✅ Loaded $($Commands.Count) commands from config file" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "❌ ERROR: Could not read config file" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Registry path for Run MRU
$RunMRUPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"

try {
    # Ensure the registry path exists
    if (!(Test-Path $RunMRUPath)) {
        Write-Host "Creating RunMRU registry path..." -ForegroundColor Yellow
        New-Item -Path $RunMRUPath -Force | Out-Null
    }

    # Get existing commands to preserve them
    Write-Host "Reading existing Run history..." -ForegroundColor Yellow
    $existingValues = @()
    try {
        $existingKeys = Get-ItemProperty -Path $RunMRUPath -ErrorAction SilentlyContinue
        if ($existingKeys) {
            $existingKeys.PSObject.Properties | Where-Object { 
                $_.Name -match '^[a-z]$' -and $_.Value -ne $null 
            } | ForEach-Object {
                $command = $_.Value -replace '\\1$', ''
                if ($command -and $command.Trim()) {
                    $existingValues += $command.Trim()
                }
            }
        }
    } catch {
        Write-Host "No existing Run history found" -ForegroundColor Green
    }

    # Combine and deduplicate commands
    $allCommands = @()
    $allCommands += $Commands  # Our commands first (higher priority)
    
    foreach ($existing in $existingValues) {
        if ($existing -notin $Commands) {
            $allCommands += $existing
        }
    }
    
    $allCommands = $allCommands | Select-Object -Unique | Select-Object -First 26

    # Clear existing RunMRU entries
    Write-Host "Updating Run history..." -ForegroundColor Yellow
    $existingItems = Get-ItemProperty -Path $RunMRUPath -ErrorAction SilentlyContinue
    if ($existingItems) {
        $existingItems.PSObject.Properties | Where-Object { 
            $_.Name -match '^[a-z]$|^MRUList$' 
        } | ForEach-Object {
            Remove-ItemProperty -Path $RunMRUPath -Name $_.Name -ErrorAction SilentlyContinue
        }
    }

    # Write commands to registry
    $letters = [char[]]([char]'a'..[char]'z')
    $mruList = ""
    
    for ($i = 0; $i -lt $allCommands.Count -and $i -lt 26; $i++) {
        $letter = $letters[$i]
        $command = $allCommands[$i]
        $registryValue = "$command\1"
        
        Set-ItemProperty -Path $RunMRUPath -Name $letter -Value $registryValue -Type String
        $mruList += $letter
        
        Write-Host "  [$letter] $command" -ForegroundColor Green
    }
    
    Set-ItemProperty -Path $RunMRUPath -Name "MRUList" -Value $mruList -Type String
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS! Commands populated from file!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Added $($allCommands.Count) commands to Win+R history" -ForegroundColor Green
    Write-Host "✅ Commands loaded from: run_commands.txt" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 To add more commands: Edit run_commands.txt and run this script again" -ForegroundColor Yellow
    Write-Host "💡 Press Win+R to test your commands!" -ForegroundColor Yellow

} catch {
    Write-Host ""
    Write-Host "❌ ERROR: Could not populate Run commands" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
