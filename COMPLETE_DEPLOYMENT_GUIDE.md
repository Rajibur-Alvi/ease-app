# 🚀 Complete Deployment Guide - Ease App

## Prerequisites Checklist

- [ ] Flutter SDK installed
- [ ] Git installed
- [ ] Android SDK configured
- [ ] GitHub account access

---

## STEP 1: Fix Android SDK Issue

### Quick Fix (If Android Studio is installed)

Open PowerShell **as Administrator** and run:

```powershell
# Set ANDROID_HOME environment variable
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')

# Add to PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$currentPath;C:\Users\new\AppData\Local\Android\Sdk\platform-tools;C:\Users\new\AppData\Local\Android\Sdk\cmdline-tools\latest\bin"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

**Then restart your terminal** and verify:

```bash
flutter doctor -v
```

### If Android Studio is NOT installed

See `SETUP_ANDROID_SDK.md` for complete installation instructions.

---

## STEP 2: Build the APK

### Option A: Use the automated script

```bash
cd ease_app
.\DEPLOY_COMMANDS.bat
```

### Option B: Manual commands

```bash
cd ease_app

# Clean previous builds
flutter clean

# Install dependencies
flutter pub get

# Accept Android licenses
flutter doctor --android-licenses

# Build release APK
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## STEP 3: Update Git Repository

### Option A: Use the automated script

```bash
cd ease_app
.\GIT_DEPLOY.bat
```

### Option B: Manual commands

```bash
cd ease_app

# Initialize git (if not already done)
git init
git remote add origin https://github.com/Rajibur-Alvi/ease-app.git

# Configure git
git config user.name "Rajibur Alvi"
git config user.email "your-email@example.com"

# Stage all files
git add .

# Commit
git commit -m "Production-ready MVP deployment"

# Push to GitHub
git push -u origin main
```

### If push fails with authentication error:

#### Option 1: Use GitHub Desktop
1. Download: https://desktop.github.com/
2. Sign in with your GitHub account
3. Add the repository
4. Push changes

#### Option 2: Use Personal Access Token
1. Go to: https://github.com/settings/tokens
2. Generate new token (classic)
3. Select scopes: `repo` (full control)
4. Copy the token
5. Push using:
```bash
git push https://YOUR_TOKEN@github.com/Rajibur-Alvi/ease-app.git main
```

#### Option 3: Use SSH
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to GitHub: https://github.com/settings/keys
# Then push
git push -u origin main
```

---

## Complete Command Sequence (Copy-Paste)

### 1. Fix Android SDK (PowerShell as Admin)

```powershell
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\new\AppData\Local\Android\Sdk', 'User')
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$currentPath;C:\Users\new\AppData\Local\Android\Sdk\platform-tools"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
```

**Restart terminal**, then:

### 2. Build APK

```bash
cd ease_app
flutter clean
flutter pub get
flutter doctor --android-licenses
flutter build apk --release
```

### 3. Update Git

```bash
git init
git remote add origin https://github.com/Rajibur-Alvi/ease-app.git
git config user.name "Rajibur Alvi"
git config user.email "your-email@example.com"
git add .
git commit -m "Production-ready MVP deployment"
git push -u origin main
```

---

## Verification

### After Android SDK setup:
```bash
flutter doctor -v
# Should show: [√] Android toolchain
```

### After APK build:
```bash
dir build\app\outputs\flutter-apk\app-release.apk
# Should show the APK file (25-35 MB)
```

### After Git push:
Visit: https://github.com/Rajibur-Alvi/ease-app
# Should show your latest commit

---

## Troubleshooting

### "ANDROID_HOME is not set"
- Run the PowerShell commands above **as Administrator**
- **Restart your terminal** after setting environment variables
- Verify: `echo $env:ANDROID_HOME`

### "Unable to locate Android SDK"
- Install Android Studio from: https://developer.android.com/studio
- Or see `SETUP_ANDROID_SDK.md` for command-line installation

### "Build failed"
```bash
flutter doctor -v
flutter clean
flutter pub get
flutter build apk --release --verbose
```

### "Git push failed"
- Check internet connection
- Verify repository URL: `git remote -v`
- Use GitHub Desktop or Personal Access Token (see above)

### "Permission denied (publickey)"
- Use HTTPS instead of SSH
- Or set up SSH keys (see above)

---

## Expected Timeline

| Task | Time |
|------|------|
| Android SDK setup | 5-15 min |
| APK build | 3-5 min |
| Git push | 1-2 min |
| **Total** | **10-25 min** |

---

## Next Steps After Deployment

1. **Test the APK**
   ```bash
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

2. **Share with testers**
   - Upload APK to Google Drive
   - Share download link
   - Collect feedback

3. **Monitor issues**
   - Check GitHub Issues
   - Track user feedback
   - Plan iterations

4. **Consider backend**
   - See `FIREBASE_MIGRATION.md`
   - Add real-time features
   - Scale to production

---

## Support

- **Documentation:** See `DOCS_INDEX.md`
- **Troubleshooting:** See `TROUBLESHOOTING.md`
- **Architecture:** See `README.md`

---

**You're ready to deploy! Start with STEP 1 above.** 🚀
