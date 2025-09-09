@echo off
REM Fix Desktop Folder Showing as Downloads
REM This script fixes the common issue where Desktop folder appears with Downloads icon/name
REM after Windows reinstallation

echo ========================================
echo Desktop Folder Fix Script
echo ========================================
echo.

REM Ensure the script runs elevated (UAC)
>nul 2>&1 fltmc
if errorlevel 1 (
  echo Elevation required. Prompting for UAC...
  powershell -nol -nop -ep Bypass -c "saps -v RunAs $env:ComSpec '/c','"%~f0" %*" -work '%~dp0'"
  exit /b
)

echo Running as Administrator... Good!
echo.

REM Get the current user's Desktop path
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
echo Desktop path: %DESKTOP_PATH%
echo.

REM Backup existing desktop.ini if it exists
if exist "%DESKTOP_PATH%\desktop.ini" (
    echo Backing up existing desktop.ini...
    copy "%DESKTOP_PATH%\desktop.ini" "%DESKTOP_PATH%\desktop.ini.backup" >nul 2>&1
    echo Backup created: desktop.ini.backup
)

REM Remove system, hidden, and read-only attributes from Desktop folder
echo Removing folder attributes...
attrib -s -h -r "%DESKTOP_PATH%" >nul 2>&1

REM Remove desktop.ini file if it exists
if exist "%DESKTOP_PATH%\desktop.ini" (
    echo Removing corrupted desktop.ini...
    attrib -s -h -r "%DESKTOP_PATH%\desktop.ini" >nul 2>&1
    del "%DESKTOP_PATH%\desktop.ini" >nul 2>&1
)
REM Create a proper desktop.ini file for Desktop folder
echo Creating proper desktop.ini...
(
echo [.ShellClassInfo]
echo LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-21769
echo IconResource=%%SystemRoot%%\system32\imageres.dll,-183
echo [ViewState]
echo Mode=
echo Vid=
echo FolderType=Generic
) > "%DESKTOP_PATH%\desktop.ini"

REM Set proper attributes for desktop.ini
attrib +s +h "%DESKTOP_PATH%\desktop.ini" >nul 2>&1

REM Set proper attributes for Desktop folder
attrib +r "%DESKTOP_PATH%" >nul 2>&1

echo.
echo Refreshing Explorer...
REM Kill and restart explorer to refresh the view
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 >nul
start explorer.exe

echo.
echo ========================================
echo Fix completed successfully!
echo ========================================
echo.
echo The Desktop folder should now display correctly.
echo If the issue persists, you may need to:
echo 1. Log off and log back in
echo 2. Restart your computer
echo 3. Run the PowerShell version of this script
echo.
echo Press any key to exit...
pause >nul
