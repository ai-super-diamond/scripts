# Desktop Folder Fix Scripts

## Problem

After reinstalling Windows, the Desktop folder sometimes appears with the "Downloads" icon and name in File Explorer. This is caused by corrupted desktop.ini files or incorrect folder attributes.

## Solution

Two scripts are provided to fix this issue:

### 1. fix_desktop_folder.bat (Batch Script)

- Simple batch file solution
- Works on all Windows versions
- **Usage:** Right-click → "Run as administrator"

### 2. fix_desktop_folder.ps1 (PowerShell Script)

- More advanced solution with registry fixes
- Better error handling and feedback
- **Usage:** Right-click PowerShell → "Run as administrator", then run the script

## What the scripts do:

1. Backup existing desktop.ini file
2. Remove corrupted attributes from Desktop folder
3. Delete the corrupted desktop.ini file
4. Create a proper desktop.ini file with correct settings
5. Set proper folder attributes
6. Fix registry entries (PowerShell version)
7. Refresh Explorer to apply changes

## Instructions:

1. **IMPORTANT:** Run as Administrator
2. Choose either the .bat or .ps1 version
3. The script will automatically fix the Desktop folder
4. If the fix doesn't work immediately, log off and back on

## Troubleshooting:

- If scripts fail to run, check Windows execution policy for PowerShell
- Some antivirus software may block the scripts
- Manual alternative: Delete desktop.ini from Desktop folder and restart Explorer

## Prevention:

Run these scripts after each Windows reinstallation to prevent the issue.
