# True Recycle Bin Emptier - No False Positives
# This script ensures actual deletion and verifies success

Write-Host "🗑️  True Recycle Bin Emptier" -ForegroundColor Cyan
Write-Host "   (Verifies actual deletion)" -ForegroundColor Gray
Write-Host ""

function Get-ItemCount {
    try {
        return (Get-ChildItem "C:\`$Recycle.Bin" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object).Count
    } catch {
        return 0
    }
}

# Check initial status
$before = Get-ItemCount
Write-Host "📊 Items before: $before" -ForegroundColor White

if ($before -eq 0) {
    Write-Host "✅ Recycle Bin is already empty!" -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "🚀 Starting deletion process..." -ForegroundColor Yellow

# Method: Direct folder-by-folder deletion with ownership changes
$success = $false
try {
    # Stop explorer to release file locks
    Write-Host "   Stopping Windows Explorer..." -ForegroundColor Gray
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Get all user folders in recycle bin
    $folders = Get-ChildItem "C:\`$Recycle.Bin" -Directory -Force -ErrorAction SilentlyContinue
    
    foreach ($folder in $folders) {
        Write-Host "   Processing: $($folder.Name)" -ForegroundColor Gray
        
        # Take ownership
        $null = takeown /f "$($folder.FullName)" /r /d y 2>$null
        $null = icacls "$($folder.FullName)" /grant administrators:F /t 2>$null
        
        # Remove attributes that might prevent deletion
        Get-ChildItem $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.Attributes = 'Normal'
            } catch { }
        }
        
        # Force delete
        Remove-Item $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Also clean any loose files
    Get-ChildItem "C:\`$Recycle.Bin" -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.Attributes = 'Normal'
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        } catch { }
    }
    
    # Restart explorer
    Write-Host "   Restarting Windows Explorer..." -ForegroundColor Gray
    Start-Process "explorer.exe"
    Start-Sleep -Seconds 3
    
    $success = $true
    
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify results
$after = Get-ItemCount
Write-Host ""
Write-Host "📊 Results:" -ForegroundColor Cyan
Write-Host "   Before: $before items" -ForegroundColor White
Write-Host "   After:  $after items" -ForegroundColor White

if ($after -eq 0) {
    Write-Host ""
    Write-Host "✅ SUCCESS! Recycle Bin is now truly empty!" -ForegroundColor Green
    Write-Host "   All $before items have been deleted." -ForegroundColor Green
} elseif ($after -lt $before) {
    $deleted = $before - $after
    Write-Host ""
    Write-Host "⚠️  PARTIAL SUCCESS!" -ForegroundColor Yellow
    Write-Host "   Deleted: $deleted items" -ForegroundColor Green
    Write-Host "   Remaining: $after items" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 For remaining items, try:" -ForegroundColor Cyan
    Write-Host "   1. Restart computer and run this script again" -ForegroundColor White
    Write-Host "   2. Boot into Safe Mode and run this script" -ForegroundColor White
    Write-Host "   3. Run recycle-bin-analyzer.ps1 to see what's stuck" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ FAILED - No items were deleted" -ForegroundColor Red
    Write-Host "   This suggests system-level protection or corruption" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Try these steps:" -ForegroundColor Cyan
    Write-Host "   1. Run as Administrator" -ForegroundColor White
    Write-Host "   2. Restart in Safe Mode" -ForegroundColor White
    Write-Host "   3. Run Windows System File Checker: sfc /scannow" -ForegroundColor White
    Write-Host "   4. Use recycle-bin-analyzer.ps1 for detailed analysis" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"
