@echo off
setlocal

echo =========================================
echo StarUML v7.0.0 License Validation PoC (Windows)
echo =========================================

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    echo Right-click on the script and select "Run as administrator".
    pause
    exit /b 1
)

:: Check if Node.js/npm is installed
where npm >nul 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] npm is not installed. Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: Install asar globally
echo [INFO] Installing asar...
call npm i asar -g

set STARUML_DIR=C:\Program Files\StarUML\resources

if not exist "%STARUML_DIR%\app.asar" (
    echo [ERROR] Could not find StarUML installation at %STARUML_DIR%
    pause
    exit /b 1
)

echo [INFO] Moving to %STARUML_DIR%
cd /d "%STARUML_DIR%"

echo [INFO] Extracting app.asar...
call asar e app.asar app

echo [INFO] Copying modified files...
copy /Y "%~dp0app\src\engine\license-store.js" "app\src\engine\license-store.js"
copy /Y "%~dp0app\src\engine\diagram-export.js" "app\src\engine\diagram-export.js"
copy /Y "%~dp0app\src\dialogs\license-activation-dialog.js" "app\src\dialogs\license-activation-dialog.js"

echo [INFO] Repacking app.asar...
call asar pack app app.asar

echo [INFO] Cleaning up...
rmdir /s /q app

echo [SUCCESS] PoC deployed successfully! (For educational testing only)
pause
