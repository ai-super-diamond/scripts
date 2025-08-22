@echo off
REM ============================================================================
REM Win+R Command Populator - Easy Launcher
REM ============================================================================
REM This batch file makes it easy to run the PowerShell script
REM Just double-click this file to populate your Win+R commands!
REM ============================================================================

title Win+R Command Populator

echo ========================================
echo Win+R Command Populator
echo ========================================
echo.
echo This will populate your Windows Run dialog (Win+R) 
echo with your favorite commands so they're always available.
echo.

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell is available'" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not available or blocked.
    echo Please run the .ps1 file directly or check your PowerShell execution policy.
    pause
    exit /b 1
)

echo Choose your option:
echo.
echo [1] Use built-in commands (from script)
echo [2] Use commands from run_commands.txt file
echo [Q] Quit
echo.
set /p choice="Enter your choice (1, 2, or Q): "

if /i "%choice%"=="1" (
    echo.
    echo Running built-in command version...
    powershell -ExecutionPolicy Bypass -File "%~dp0populate_run_commands.ps1"
) else if /i "%choice%"=="2" (
    echo.
    echo Running file-based version...
    if not exist "%~dp0run_commands.txt" (
        echo ERROR: run_commands.txt not found!
        echo Please make sure the file exists in this folder.
        pause
        exit /b 1
    )
    powershell -ExecutionPolicy Bypass -File "%~dp0populate_run_commands_from_file.ps1"
) else if /i "%choice%"=="Q" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice. Please try again.
    pause
    goto :eof
)

echo.
echo Done! You can now close this window.
pause
