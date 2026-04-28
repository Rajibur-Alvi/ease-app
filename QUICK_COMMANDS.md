# 🚀 Quick Command Reference

## 1️⃣ FIX ANDROID SDK

### Open PowerShell as Administrator, then run:

```powershell
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')
```

**Restart your terminal**, then verify:

```bash
flutter doctor -v
```

---

## 2️⃣ BUILD APK

```bash
cd ease_app
flutter clean
flutter pub get
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 3️⃣ UPDATE GIT REPOSITORY

```bash
cd ease_app
git init
git remote add origin https://github.com/Rajibur-Alvi/ease-app.git
git add .
git commit -m "Production-ready MVP deployment"
git push -u origin main
```

---

## 🎯 ONE-CLICK DEPLOYMENT

### Use the master script:

```bash
cd ease_app
.\MASTER_DEPLOY.bat
```

This script does everything automatically!

---

## 📋 Individual Scripts

| Script | Purpose |
|--------|---------|
| `MASTER_DEPLOY.bat` | Complete deployment (all steps) |
| `DEPLOY_COMMANDS.bat` | Build APK only |
| `GIT_DEPLOY.bat` | Git push only |

---

## ⚡ Super Quick (If SDK is already set up)

```bash
cd ease_app
flutter build apk --release && git add . && git commit -m "Update" && git push
```

---

## 🔍 Verification Commands

```bash
# Check Android SDK
echo $env:ANDROID_HOME

# Check Flutter
flutter doctor -v

# Check APK exists
dir build\app\outputs\flutter-apk\app-release.apk

# Check Git status
git status

# Check Git remote
git remote -v
```

---

## 🆘 If Something Fails

### Android SDK not found
```powershell
# PowerShell as Admin
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')
```
Then restart terminal.

### Build fails
```bash
flutter clean
flutter pub get
flutter doctor --android-licenses
flutter build apk --release --verbose
```

### Git push fails
```bash
# Use GitHub Desktop (easiest)
# Or use Personal Access Token:
git push https://YOUR_TOKEN@github.com/Rajibur-Alvi/ease-app.git main
```

---

## 📱 Install APK on Device

```bash
# Connect device via USB
adb devices

# Install
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## 📚 Full Documentation

- `COMPLETE_DEPLOYMENT_GUIDE.md` - Step-by-step guide
- `SETUP_ANDROID_SDK.md` - Android SDK installation
- `TROUBLESHOOTING.md` - Common issues
- `DEPLOY_NOW.md` - Quick start

---

**Choose your path:**
- ⚡ **Fast:** Run `.\MASTER_DEPLOY.bat`
- 🎯 **Manual:** Copy commands from sections 1-3 above
- 📖 **Detailed:** Read `COMPLETE_DEPLOYMENT_GUIDE.md`
