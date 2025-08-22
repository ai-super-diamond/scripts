# Aggressive Recycle Bin Cleaner - Handles Stubborn Files
# This script verifies actual deletion and uses multiple forceful methods

Write-Host "=== Aggressive Recycle Bin Cleaner ===" -ForegroundColor Red
Write-Host ""

# Function to count items with verification
function Get-RecycleBinItemCount {
    try {
        $items = Get-ChildItem "C:\`$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue
        return ($items | Measure-Object).Count
    } catch {
        return -1
    }
}

# Function to get folder sizes
function Get-RecycleBinSize {
    try {
        $size = (Get-ChildItem "C:\`$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    } catch {
        return 0
    }
}

# Initial count
$initialCount = Get-RecycleBinItemCount
$initialSize = Get-RecycleBinSize

Write-Host "📊 Initial Status:" -ForegroundColor Cyan
Write-Host "   Items: $initialCount" -ForegroundColor White
Write-Host "   Size: $initialSize MB" -ForegroundColor White
Write-Host ""

if ($initialCount -eq 0) {
    Write-Host "✅ Recycle Bin is already empty!" -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "🚀 Starting aggressive cleanup..." -ForegroundColor Yellow
Write-Host ""

# Method 1: Standard Clear-RecycleBin
Write-Host "Method 1: Standard Clear-RecycleBin..." -ForegroundColor Yellow
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Start-Sleep -Seconds 3
    
    $count1 = Get-RecycleBinItemCount
    Write-Host "   Result: $count1 items remaining" -ForegroundColor $(if($count1 -lt $initialCount){"Green"}else{"Red"})
} catch {
    Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
    $count1 = $initialCount
}

if ($count1 -gt 0) {
    # Method 2: Force delete each user folder
    Write-Host "Method 2: Per-user folder deletion..." -ForegroundColor Yellow
    
    $userFolders = Get-ChildItem "C:\`$Recycle.Bin" -Directory -Force -ErrorAction SilentlyContinue
    foreach ($folder in $userFolders) {
        Write-Host "   Deleting: $($folder.Name)" -ForegroundColor Gray
        try {
            # Take ownership first
            takeown /f "$($folder.FullName)" /r /d y 2>$null | Out-Null
            icacls "$($folder.FullName)" /grant administrators:F /t 2>$null | Out-Null
            
            # Force delete
            Remove-Item $folder.FullName -Recurse -Force -ErrorAction Stop
            Write-Host "   ✅ Deleted: $($folder.Name)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Failed: $($folder.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Seconds 2
    $count2 = Get-RecycleBinItemCount
    Write-Host "   Result: $count2 items remaining" -ForegroundColor $(if($count2 -lt $count1){"Green"}else{"Red"})
} else {
    $count2 = 0
}

if ($count2 -gt 0) {
    # Method 3: Nuclear option - recreate the folder
    Write-Host "Method 3: Nuclear option - recreate recycle bin..." -ForegroundColor Red
    try {
        # Stop explorer to release locks
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        
        # Take ownership of entire recycle bin
        takeown /f "C:\`$Recycle.Bin" /r /d y 2>$null | Out-Null
        icacls "C:\`$Recycle.Bin" /grant administrators:F /t 2>$null | Out-Null
        
        # Remove the entire folder
        cmd /c 'rd /s /q "C:\$Recycle.Bin"' 2>$null
        
        # Recreate empty recycle bin
        New-Item -Path "C:\`$Recycle.Bin" -ItemType Directory -Force | Out-Null
        
        # Restart explorer
        Start-Process "explorer.exe"
        Start-Sleep -Seconds 3
        
        $count3 = Get-RecycleBinItemCount
        Write-Host "   Result: $count3 items remaining" -ForegroundColor $(if($count3 -eq 0){"Green"}else{"Red"})
    } catch {
        Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
        $count3 = $count2
    }
} else {
    $count3 = 0
}

if ($count3 -gt 0) {
    # Method 4: System-level commands
    Write-Host "Method 4: System-level cleanup..." -ForegroundColor Red
    try {
        # Use system utilities
        cmd /c 'for /f %i in ('"'"'dir "C:\$Recycle.Bin" /b /s 2^>nul'"'"') do del /f /q "%i" 2>nul'
        cmd /c 'for /f %i in ('"'"'dir "C:\$Recycle.Bin" /b /s /ad 2^>nul'"'"') do rd /s /q "%i" 2>nul'
        
        Start-Sleep -Seconds 2
        $count4 = Get-RecycleBinItemCount
        Write-Host "   Result: $count4 items remaining" -ForegroundColor $(if($count4 -lt $count3){"Green"}else{"Red"})
    } catch {
        Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
        $count4 = $count3
    }
} else {
    $count4 = 0
}

# Final verification
Write-Host ""
Write-Host "=== Final Results ===" -ForegroundColor Cyan
$finalCount = Get-RecycleBinItemCount
$finalSize = Get-RecycleBinSize

Write-Host "📊 Before: $initialCount items ($initialSize MB)" -ForegroundColor White
Write-Host "📊 After:  $finalCount items ($finalSize MB)" -ForegroundColor White

if ($finalCount -eq 0) {
    Write-Host ""
    Write-Host "🎉 SUCCESS! Recycle Bin is now completely empty!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  WARNING: $finalCount items still remain" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Remaining items may be:" -ForegroundColor Yellow
    Write-Host "• System-protected files" -ForegroundColor Gray
    Write-Host "• Files in use by running processes" -ForegroundColor Gray
    Write-Host "• Files requiring reboot to delete" -ForegroundColor Gray
    
    if ($finalCount -lt $initialCount) {
        $deleted = $initialCount - $finalCount
        Write-Host ""
        Write-Host "✅ Partial success: Deleted $deleted out of $initialCount items" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
