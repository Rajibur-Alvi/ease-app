@echo off
REM Ease App - Pre-Deployment Checklist (Windows)
REM Run this before building release APK

echo.
echo ================================
echo Ease App - Pre-Deployment Check
echo ================================
echo.

set ERRORS=0

REM 1. Check Flutter installation
echo 1. Checking Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Flutter found
    flutter --version | findstr /C:"Flutter"
) else (
    echo [ERROR] Flutter not found
    set /a ERRORS+=1
)
echo.

REM 2. Run flutter doctor
echo 2. Running flutter doctor...
flutter doctor
echo.

REM 3. Clean previous builds
echo 3. Cleaning previous builds...
flutter clean
if %ERRORLEVEL% EQU 0 (
    echo [OK] Clean successful
) else (
    echo [ERROR] Clean failed
    set /a ERRORS+=1
)
echo.

REM 4. Get dependencies
echo 4. Getting dependencies...
flutter pub get
if %ERRORLEVEL% EQU 0 (
    echo [OK] Dependencies installed
) else (
    echo [ERROR] Dependency installation failed
    set /a ERRORS+=1
)
echo.

REM 5. Run code analysis
echo 5. Running code analysis...
flutter analyze --no-fatal-infos
if %ERRORLEVEL% EQU 0 (
    echo [OK] No errors found
) else (
    echo [WARNING] Analysis warnings found
)
echo.

REM 6. Run tests
echo 6. Running tests...
flutter test
if %ERRORLEVEL% EQU 0 (
    echo [OK] All tests passed
) else (
    echo [ERROR] Tests failed
    set /a ERRORS+=1
)
echo.

REM 7. Check assets directory
echo 7. Checking assets...
if exist "assets\images" (
    echo [OK] Assets directory exists
) else (
    echo [WARNING] Assets directory missing - creating...
    mkdir assets\images
)
echo.

REM 8. Verify pubspec.yaml
echo 8. Verifying pubspec.yaml...
findstr /C:"version:" pubspec.yaml >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Version found in pubspec.yaml
) else (
    echo [ERROR] Version not found
    set /a ERRORS+=1
)
echo.

REM Summary
echo ================================
if %ERRORS% EQU 0 (
    echo [SUCCESS] All checks passed!
    echo.
    echo Ready to build:
    echo   flutter build apk --release
    echo.
) else (
    echo [FAILED] %ERRORS% error(s) found
    echo Fix errors before deploying
    exit /b 1
)

pause
