# Recycle Bin File Analysis - Shows what's preventing deletion
# This script analyzes the stubborn files in detail

Write-Host "=== Recycle Bin File Analysis ===" -ForegroundColor Cyan
Write-Host ""

$recycleBinPath = "C:\`$Recycle.Bin"

if (-not (Test-Path $recycleBinPath)) {
    Write-Host "❌ Recycle Bin folder not found!" -ForegroundColor Red
    exit
}

Write-Host "🔍 Analyzing Recycle Bin contents..." -ForegroundColor Yellow
Write-Host ""

# Get all items
try {
    $allItems = Get-ChildItem $recycleBinPath -Recurse -Force -ErrorAction SilentlyContinue
    $totalCount = ($allItems | Measure-Object).Count
    
    Write-Host "📊 Total items found: $totalCount" -ForegroundColor Cyan
    
    # Analyze by user folders
    $userFolders = Get-ChildItem $recycleBinPath -Directory -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "👥 User Folders Analysis:" -ForegroundColor Yellow
    
    foreach ($folder in $userFolders) {
        $folderItems = Get-ChildItem $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
        $itemCount = ($folderItems | Measure-Object).Count
        $folderSize = ($folderItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeMB = if ($folderSize) { [math]::Round($folderSize / 1MB, 2) } else { 0 }
        
        Write-Host "   📁 $($folder.Name): $itemCount items ($sizeMB MB)" -ForegroundColor White
        
        # Check permissions
        try {
            $acl = Get-Acl $folder.FullName -ErrorAction SilentlyContinue
            $owner = $acl.Owner
            Write-Host "      Owner: $owner" -ForegroundColor Gray
        } catch {
            Write-Host "      Owner: Unable to determine" -ForegroundColor Red
        }
        
        # Check for locked files
        $lockedFiles = 0
        foreach ($item in $folderItems) {
            if ($item.PSIsContainer) { continue }
            try {
                $stream = [System.IO.File]::Open($item.FullName, 'Open', 'Write')
                $stream.Close()
            } catch {
                $lockedFiles++
            }
        }
        
        if ($lockedFiles -gt 0) {
            Write-Host "      🔒 Locked files: $lockedFiles" -ForegroundColor Red
        }
        
        # Show sample files
        if ($itemCount -gt 0) {
            Write-Host "      Sample files:" -ForegroundColor Gray
            $folderItems | Where-Object { -not $_.PSIsContainer } | Select-Object -First 3 | ForEach-Object {
                $fileName = $_.Name
                $fileSize = if ($_.Length) { [math]::Round($_.Length / 1KB, 1) } else { 0 }
                Write-Host "        - $fileName ($fileSize KB)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }
    
    # Check for system files
    Write-Host "🔍 System File Analysis:" -ForegroundColor Yellow
    $systemFiles = $allItems | Where-Object { $_.Attributes -match "System" }
    $hiddenFiles = $allItems | Where-Object { $_.Attributes -match "Hidden" }
    $readOnlyFiles = $allItems | Where-Object { $_.Attributes -match "ReadOnly" }
    
    Write-Host "   System files: $(($systemFiles | Measure-Object).Count)" -ForegroundColor White
    Write-Host "   Hidden files: $(($hiddenFiles | Measure-Object).Count)" -ForegroundColor White
    Write-Host "   Read-only files: $(($readOnlyFiles | Measure-Object).Count)" -ForegroundColor White
    
    # Check for long paths
    $longPaths = $allItems | Where-Object { $_.FullName.Length -gt 260 }
    if ($longPaths) {
        Write-Host "   Long path files: $(($longPaths | Measure-Object).Count)" -ForegroundColor Red
        Write-Host "     (Paths longer than 260 characters can cause issues)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "💡 Recommendations:" -ForegroundColor Green
    
    if ($totalCount -gt 0) {
        Write-Host "   1. Run aggressive-recycle-cleaner.ps1 as Administrator" -ForegroundColor White
        Write-Host "   2. If that fails, restart in Safe Mode and try again" -ForegroundColor White
        Write-Host "   3. Consider using third-party tools like CCleaner" -ForegroundColor White
        Write-Host "   4. Last resort: Backup data and create new user profile" -ForegroundColor White
    }
    
} catch {
    Write-Host "❌ Error analyzing recycle bin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Analysis Complete ===" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
