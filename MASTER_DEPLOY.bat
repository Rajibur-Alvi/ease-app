@echo off
REM ============================================================
REM EASE APP - MASTER DEPLOYMENT SCRIPT
REM This script handles: Android SDK check, Build APK, Git Push
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo                 EASE APP MASTER DEPLOYMENT
echo ============================================================
echo.
echo This script will:
echo   1. Check Android SDK configuration
echo   2. Build release APK
echo   3. Update Git repository
echo.
echo Repository: https://github.com/Rajibur-Alvi/ease-app.git
echo.
pause

REM ============================================================
REM STEP 1: CHECK ANDROID SDK
REM ============================================================

echo.
echo ============================================================
echo STEP 1: CHECKING ANDROID SDK
echo ============================================================
echo.

if not defined ANDROID_HOME (
    echo [ERROR] ANDROID_HOME is not set!
    echo.
    echo SOLUTION: Run this command in PowerShell as Administrator:
    echo.
    echo [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\%USERNAME%\AppData\Local\Android\Sdk', 'User'^)
    echo.
    echo Then restart this terminal and run this script again.
    echo.
    echo For detailed instructions, see: SETUP_ANDROID_SDK.md
    echo.
    pause
    exit /b 1
)

echo [OK] ANDROID_HOME is set: %ANDROID_HOME%

if not exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    echo [WARNING] Android SDK tools not found at: %ANDROID_HOME%
    echo Please verify your Android SDK installation.
    echo.
    pause
)

echo.
echo Checking Flutter doctor...
flutter doctor
echo.

set /p continue1="Continue with build? (y/n): "
if /i not "%continue1%"=="y" exit /b 0

REM ============================================================
REM STEP 2: BUILD APK
REM ============================================================

echo.
echo ============================================================
echo STEP 2: BUILDING RELEASE APK
echo ============================================================
echo.

echo [1/4] Cleaning previous build...
flutter clean
if errorlevel 1 (
    echo [ERROR] Flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/4] Installing dependencies...
flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [3/4] Accepting Android licenses...
flutter doctor --android-licenses
echo.

echo [4/4] Building release APK...
echo This may take 3-5 minutes. Please wait...
echo.
flutter build apk --release
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    echo.
    echo Troubleshooting:
    echo 1. Run: flutter doctor -v
    echo 2. Check: TROUBLESHOOTING.md
    echo 3. Verify Android SDK is properly installed
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo BUILD SUCCESSFUL!
echo ============================================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        set size=%%~zA
        set /a sizeMB=!size! / 1048576
        echo APK Size: !sizeMB! MB
    )
)

echo.
set /p continue2="Continue with Git push? (y/n): "
if /i not "%continue2%"=="y" (
    echo.
    echo Deployment stopped. APK is ready at:
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
    pause
    exit /b 0
)

REM ============================================================
REM STEP 3: GIT REPOSITORY UPDATE
REM ============================================================

echo.
echo ============================================================
echo STEP 3: UPDATING GIT REPOSITORY
echo ============================================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed!
    echo Download from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

REM Initialize git if needed
if not exist ".git" (
    echo Initializing Git repository...
    git init
    git remote add origin https://github.com/Rajibur-Alvi/ease-app.git
    echo.
)

REM Configure git
echo Configuring Git...
git config user.name "Rajibur Alvi"
set /p email="Enter your email (or press Enter for default): "
if "%email%"=="" set email=rajibur.alvi@example.com
git config user.email "%email%"
echo.

REM Check current branch
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set current_branch=%%i
if "%current_branch%"=="" (
    echo Creating main branch...
    git checkout -b main
)

REM Add files
echo [1/4] Staging files...
git add .
echo.

REM Commit
echo [2/4] Creating commit...
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Production-ready MVP deployment - APK built

git commit -m "%commit_msg%"
if errorlevel 1 (
    echo No changes to commit or commit failed
    echo.
)

REM Show remote
echo [3/4] Remote repository:
git remote -v
echo.

REM Push
echo [4/4] Pushing to GitHub...
echo.
git push -u origin main
if errorlevel 1 (
    echo.
    echo [ERROR] Push failed!
    echo.
    echo Common solutions:
    echo.
    echo 1. Use GitHub Desktop (easiest):
    echo    Download: https://desktop.github.com/
    echo.
    echo 2. Use Personal Access Token:
    echo    a. Go to: https://github.com/settings/tokens
    echo    b. Generate new token with 'repo' scope
    echo    c. Run: git push https://YOUR_TOKEN@github.com/Rajibur-Alvi/ease-app.git main
    echo.
    echo 3. Try different branch name:
    echo    git push -u origin master
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo DEPLOYMENT COMPLETE!
echo ============================================================
echo.
echo [√] APK built successfully
echo [√] Git repository updated
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo Repository: https://github.com/Rajibur-Alvi/ease-app.git
echo.
echo Next Steps:
echo 1. Test APK: adb install build\app\outputs\flutter-apk\app-release.apk
echo 2. Share APK with testers
echo 3. Visit GitHub to verify push
echo.
pause
