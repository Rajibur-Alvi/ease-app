@echo off
REM ============================================================
REM Ease App - Complete Deployment Script for Windows
REM ============================================================

echo.
echo ========================================
echo   EASE APP DEPLOYMENT
echo ========================================
echo.

REM Check if Android SDK is configured
echo [1/6] Checking Android SDK...
if not defined ANDROID_HOME (
    echo.
    echo ERROR: ANDROID_HOME is not set!
    echo.
    echo Please run ONE of these commands first:
    echo.
    echo Option A - If Android Studio is installed:
    echo [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\%USERNAME%\AppData\Local\Android\Sdk', 'User'^)
    echo.
    echo Option B - If using command-line tools:
    echo [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android\Sdk', 'User'^)
    echo.
    echo Then restart this terminal and run this script again.
    echo See SETUP_ANDROID_SDK.md for detailed instructions.
    echo.
    pause
    exit /b 1
)

echo Android SDK found at: %ANDROID_HOME%
echo.

REM Verify Flutter
echo [2/6] Verifying Flutter installation...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found! Install from https://flutter.dev
    pause
    exit /b 1
)
echo.

REM Clean build
echo [3/6] Cleaning previous build...
flutter clean
echo.

REM Get dependencies
echo [4/6] Installing dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)
echo.

REM Accept licenses
echo [5/6] Checking Android licenses...
flutter doctor --android-licenses
echo.

REM Build APK
echo [6/6] Building release APK...
echo This may take 3-5 minutes...
echo.
flutter build apk --release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Run 'flutter doctor -v' to diagnose issues
    pause
    exit /b 1
)

echo.
echo ========================================
echo   BUILD SUCCESSFUL!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo Next Steps:
echo 1. Install on device: adb install build\app\outputs\flutter-apk\app-release.apk
echo 2. Or share the APK file directly
echo.
pause
