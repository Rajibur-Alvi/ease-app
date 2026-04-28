# Troubleshooting Guide

Common issues and solutions for building and deploying Ease.

---

## 🔧 Build Issues

### "Android SDK not found"

**Problem:** Flutter can't locate Android SDK.

**Solution:**
1. Install Android Studio: https://developer.android.com/studio
2. Open Android Studio → SDK Manager → Install Android SDK
3. Set environment variable:
   ```bash
   # Linux/Mac
   export ANDROID_HOME=$HOME/Android/Sdk
   
   # Windows (PowerShell)
   $env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"
   ```
4. Run: `flutter config --android-sdk $ANDROID_HOME`
5. Verify: `flutter doctor`

---

### "Gradle build failed"

**Problem:** Gradle sync or build errors.

**Solution:**
1. Clean project:
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   ```
2. Delete build cache:
   ```bash
   rm -rf build/
   rm -rf android/.gradle/
   ```
3. Rebuild:
   ```bash
   flutter pub get
   flutter build apk --release
   ```

---

### "Dependency version conflict"

**Problem:** Package version incompatibilities.

**Solution:**
1. Update dependencies:
   ```bash
   flutter pub upgrade
   ```
2. If still failing, check `pubspec.yaml` for version constraints
3. Run: `flutter pub outdated` to see available updates

---

## 📱 Runtime Issues

### App crashes on startup

**Possible causes:**
1. **Missing permissions** — Check `AndroidManifest.xml` has required permissions
2. **Database initialization** — Delete app data and reinstall
3. **Null safety** — Check logs: `flutter logs`

**Solution:**
```bash
# View logs
adb logcat | grep flutter

# Reinstall clean
adb uninstall com.example.ease_app
flutter install
```

---

### "Speech recognition not working"

**Problem:** Voice input doesn't activate.

**Solution:**
1. Grant microphone permission in app settings
2. Ensure device has Google Speech Services installed
3. Test on physical device (emulator may not support speech)

---

### Notifications not showing

**Problem:** Daily reminders don't trigger.

**Solution:**
1. Grant notification permission
2. Check battery optimization settings (disable for Ease)
3. Verify timezone is set correctly
4. Test manually:
   ```dart
   await NotificationService().scheduleDailyBrainDumpReminder();
   ```

---

### Chat messages not persisting

**Problem:** Messages disappear after app restart.

**Solution:**
1. Check SQLite database is being created:
   ```bash
   adb shell
   run-as com.example.ease_app
   ls databases/
   # Should show: ease_v2.db
   ```
2. If missing, check write permissions
3. Clear app data and retry

---

## 🐛 Development Issues

### "Hot reload not working"

**Solution:**
```bash
# Stop app
# Run with verbose logging
flutter run -v
```

---

### "Import errors in IDE"

**Solution:**
1. Run: `flutter pub get`
2. Restart IDE
3. Invalidate caches (Android Studio: File → Invalidate Caches)

---

### "Analysis errors but app runs fine"

**Solution:**
```bash
# Run analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

---

## 📦 APK Issues

### APK size too large

**Current size:** ~25-35 MB

**To reduce:**
```bash
# Build split APKs per architecture
flutter build apk --release --split-per-abi

# Generates:
# - app-armeabi-v7a-release.apk (~18 MB)
# - app-arm64-v8a-release.apk (~20 MB)
# - app-x86_64-release.apk (~22 MB)
```

---

### "App not installing on device"

**Possible causes:**
1. **Insufficient storage** — Free up space
2. **Architecture mismatch** — Use `--split-per-abi` and install correct variant
3. **Signature conflict** — Uninstall old version first

**Solution:**
```bash
# Uninstall old version
adb uninstall com.example.ease_app

# Install new APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔍 Debugging Tips

### Enable verbose logging

```bash
flutter run --verbose
```

### Check device logs

```bash
# Android
adb logcat | grep -i flutter

# Filter by app
adb logcat | grep com.example.ease_app
```

### Inspect database

```bash
adb shell
run-as com.example.ease_app
cd databases
sqlite3 ease_v2.db
.tables
SELECT * FROM chat_messages;
.quit
```

### Check SharedPreferences

```bash
adb shell
run-as com.example.ease_app
cd shared_prefs
cat *.xml
```

---

## 🆘 Still Having Issues?

1. **Check Flutter version:** `flutter --version` (should be 3.11+)
2. **Update Flutter:** `flutter upgrade`
3. **Clean everything:**
   ```bash
   flutter clean
   flutter pub get
   flutter doctor -v
   ```
4. **Review logs:** Look for stack traces in console output
5. **Test on different device:** Some issues are device-specific

---

## 📞 Getting Help

If you're still stuck:
1. Run: `flutter doctor -v` and share output
2. Share error logs from `flutter run -v`
3. Describe exact steps to reproduce
4. Mention device model and Android version

---

**Most issues are resolved by:**
```bash
flutter clean && flutter pub get && flutter build apk --release
```
