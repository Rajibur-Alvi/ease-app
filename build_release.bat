@echo off
REM Ease App - Release Build Script (Windows)
REM Builds production-ready APK

echo.
echo ================================
echo Building Ease App for Release
echo ================================
echo.

REM Step 1: Clean
echo 1. Cleaning previous builds...
flutter clean
echo.

REM Step 2: Get dependencies
echo 2. Installing dependencies...
flutter pub get
echo.

REM Step 3: Build APK
echo 3. Building release APK...
flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Build successful!
    echo.
    echo APK Location:
    echo   build\app\outputs\flutter-apk\app-release.apk
    echo.
    
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo APK Size: %%~zA bytes
        echo.
    )
    
    echo Next steps:
    echo   1. Test the APK on a device
    echo   2. Install: adb install build\app\outputs\flutter-apk\app-release.apk
    echo   3. Or share the APK file directly
    echo.
) else (
    echo.
    echo [FAILED] Build failed
    echo Check errors above and try again
    exit /b 1
)

pause
