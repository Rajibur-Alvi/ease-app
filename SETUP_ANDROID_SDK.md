# Android SDK Setup Guide for Windows

## Option 1: Install Android Studio (Recommended)

### Step 1: Download Android Studio
1. Visit: https://developer.android.com/studio
2. Download Android Studio for Windows
3. Run the installer

### Step 2: Install Android SDK via Android Studio
1. Open Android Studio
2. Click "More Actions" → "SDK Manager"
3. Install:
   - Android SDK Platform (API 34 or latest)
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
4. Note the SDK location (usually: `C:\Users\YourName\AppData\Local\Android\Sdk`)

### Step 3: Set Environment Variables
Run these commands in PowerShell (as Administrator):

```powershell
# Set ANDROID_HOME
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')

# Add to PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$currentPath;C:\Users\new\AppData\Local\Android\Sdk\platform-tools;C:\Users\new\AppData\Local\Android\Sdk\cmdline-tools\latest\bin"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

### Step 4: Restart Terminal and Verify
```bash
flutter doctor --android-licenses
flutter doctor -v
```

---

## Option 2: Command-Line Only (Without Android Studio)

### Step 1: Download Command Line Tools
1. Visit: https://developer.android.com/studio#command-line-tools-only
2. Download "Command line tools only" for Windows
3. Extract to: `C:\Android\Sdk\cmdline-tools\latest`

### Step 2: Set Environment Variables
```powershell
# Create SDK directory
New-Item -ItemType Directory -Force -Path "C:\Android\Sdk"

# Set ANDROID_HOME
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android\Sdk', 'User')

# Add to PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$currentPath;C:\Android\Sdk\platform-tools;C:\Android\Sdk\cmdline-tools\latest\bin"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

### Step 3: Install SDK Components
Restart PowerShell, then run:

```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
sdkmanager --licenses
```

### Step 4: Verify
```bash
flutter doctor -v
```

---

## Quick Fix Commands (Copy-Paste)

### If Android Studio is already installed but Flutter can't find it:

```powershell
# Find your Android SDK location
Get-ChildItem -Path "$env:LOCALAPPDATA\Android" -Recurse -Filter "adb.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty DirectoryName

# Then set ANDROID_HOME to the Sdk folder (parent of platform-tools)
# Example:
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')

# Restart terminal
flutter doctor -v
```

---

## Troubleshooting

### "Unable to locate Android SDK"
- Verify ANDROID_HOME is set: `echo $env:ANDROID_HOME`
- Verify PATH includes platform-tools: `echo $env:PATH`
- Restart your terminal/IDE after setting environment variables

### "Android license status unknown"
```bash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

### "cmdline-tools component is missing"
```bash
sdkmanager "cmdline-tools;latest"
```

---

## After Setup

Once Android SDK is configured:

```bash
cd ease_app
flutter doctor -v
flutter clean
flutter pub get
flutter build apk --release
```

Your APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
