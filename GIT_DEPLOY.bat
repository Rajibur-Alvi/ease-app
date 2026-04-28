@echo off
REM ============================================================
REM Git Repository Update Script
REM Repository: https://github.com/Rajibur-Alvi/ease-app.git
REM ============================================================

echo.
echo ========================================
echo   GIT REPOSITORY UPDATE
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed!
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Check if .git exists
if not exist ".git" (
    echo Initializing Git repository...
    git init
    git remote add origin https://github.com/Rajibur-Alvi/ease-app.git
    echo.
)

REM Configure git (update with your details)
echo Configuring Git...
git config user.name "Rajibur Alvi"
git config user.email "rajibur.alvi@example.com"
echo.

REM Add all files
echo [1/5] Staging all files...
git add .
echo.

REM Commit
echo [2/5] Creating commit...
set /p commit_message="Enter commit message (or press Enter for default): "
if "%commit_message%"=="" set commit_message=Production-ready MVP deployment

git commit -m "%commit_message%"
if errorlevel 1 (
    echo No changes to commit or commit failed
)
echo.

REM Check remote
echo [3/5] Verifying remote repository...
git remote -v
echo.

REM Pull latest (if needed)
echo [4/5] Pulling latest changes...
git pull origin main --rebase
if errorlevel 1 (
    echo Note: Pull failed or no remote branch. Continuing...
)
echo.

REM Push to GitHub
echo [5/5] Pushing to GitHub...
git push -u origin main
if errorlevel 1 (
    echo.
    echo ERROR: Push failed!
    echo.
    echo Possible reasons:
    echo 1. Authentication required - set up GitHub credentials
    echo 2. Branch name mismatch - try: git push -u origin master
    echo 3. No internet connection
    echo.
    echo To set up authentication:
    echo - Use GitHub Desktop, OR
    echo - Generate Personal Access Token at: https://github.com/settings/tokens
    echo - Use: git push https://YOUR_TOKEN@github.com/Rajibur-Alvi/ease-app.git main
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   PUSH SUCCESSFUL!
echo ========================================
echo.
echo Repository: https://github.com/Rajibur-Alvi/ease-app.git
echo.
pause
