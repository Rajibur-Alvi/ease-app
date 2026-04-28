@echo off
REM ============================================================
REM ANDROID SDK INSTALLER - Downloads and installs Android SDK
REM ============================================================

echo.
echo ============================================================
echo   ANDROID SDK INSTALLATION
echo ============================================================
echo.

REM Check if Android SDK already exists
if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    echo [OK] Android SDK is already installed!
    echo Location: C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo.
    goto :configure
)

echo Android SDK is not installed.
echo.
echo OPTION 1: Install Android Studio (Recommended)
echo   1. Download from: https://developer.android.com/studio
echo   2. Run the installer
echo   3. Follow the setup wizard
echo   4. SDK will be installed automatically
echo.
echo OPTION 2: Download Command Line Tools Only
echo   1. Visit: https://developer.android.com/studio#command-line-tools-only
echo   2. Download "Command line tools only" for Windows
echo   3. Extract to: C:\Android\Sdk\cmdline-tools\latest
echo.
set /p choice="Which option? (1 for Studio, 2 for CLI, 3 to skip): "

if "%choice%"=="1" (
    echo.
    echo Opening Android Studio download page...
    start https://developer.android.com/studio
    echo.
    echo After installation:
    echo 1. Open Android Studio
    echo 2. Complete the setup wizard
    echo 3. SDK will be installed automatically
    echo 4. Run this script again
    echo.
    pause
    exit /b 0
)

if "%choice%"=="2" (
    echo.
    echo Opening Command Line Tools download page...
    start https://developer.android.com/studio#command-line-tools-only
    echo.
    echo After download:
    echo 1. Extract the zip file
    echo 2. Create folder: C:\Android\Sdk\cmdline-tools\latest
    echo 3. Move contents to that folder
    echo 4. Run this script again
    echo.
    pause
    exit /b 0
)

:configure
echo.
echo ============================================================
echo   CONFIGURING ENVIRONMENT VARIABLES
echo ============================================================
echo.

REM Detect SDK location
set SDK_PATH=
if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk" (
    set SDK_PATH=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
) else if exist "C:\Android\Sdk" (
    set SDK_PATH=C:\Android\Sdk
)

if "%SDK_PATH%"=="" (
    echo [ERROR] Could not find Android SDK!
    echo Please install Android SDK first.
    pause
    exit /b 1
)

echo Found Android SDK at: %SDK_PATH%
echo.
echo Setting ANDROID_HOME environment variable...
echo.
echo Run this command in PowerShell as Administrator:
echo.
echo [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', '%SDK_PATH%', 'User'^)
echo.
echo Then add to PATH:
echo $currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User'^)
echo $newPath = "$currentPath;%SDK_PATH%\platform-tools;%SDK_PATH%\cmdline-tools\latest\bin"
echo [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User'^)
echo.
echo.
set /p auto="Do you want to open PowerShell as Admin now? (y/n): "
if /i "%auto%"=="y" (
    echo.
    echo Opening PowerShell as Administrator...
    echo Copy and paste the commands shown above.
    echo.
    powershell -Command "Start-Process powershell -Verb RunAs"
)

echo.
echo After setting environment variables:
echo 1. Restart your terminal
echo 2. Run: flutter doctor -v
echo 3. Run: .\MASTER_DEPLOY.bat
echo.
pause
