# Ease — Emotional Wellbeing & Gentle Connection

A calm, minimal app for emotional reflection, life organization, and gentle social connection designed for introverted users.

---

## 🌿 What is Ease?

Ease helps you:
- **Unload thoughts** through Brain Dump
- **Organize life areas** across 8 departments (Health, Work, Finance, Family, etc.)
- **Connect gently** with others who understand you
- **Track progress** with lightweight analytics

**100% offline-first.** All data stays on your device.

---

## ✨ Key Features

### 🧠 Brain Dump
- Text + voice input
- Auto-categorizes into life areas
- Suggests small actionable steps
- Persistent local storage

### 🏠 Life Departments
- 8 categories with progress tracking
- Micro-task management
- Status indicators (Stable / In Progress / Needs Attention)

### 💬 Gentle Connection
- Match with others based on interests + mood
- Local chat with auto-reply
- Introvert-friendly design

### 📊 Analytics
- Brain Dump streak tracking
- Mood frequency analysis
- Weekly activity summary

### 🔔 Daily Reminders
- Gentle Brain Dump reminder (8pm)
- Morning mood check-in (9am)
- Fully customizable

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repo-url>
cd ease_app

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## 📱 Screenshots

*(Add screenshots here after deployment)*

---

## 🏗️ Tech Stack

- **Framework:** Flutter 3.41+
- **State Management:** Provider
- **Navigation:** Go Router
- **Local Storage:** SharedPreferences + SQLite
- **Notifications:** flutter_local_notifications
- **UI:** Material 3 with custom design system

---

## 📂 Project Structure

```
lib/
├── models/           # Data models
├── services/         # Business logic
├── ui/
│   ├── screens/      # App screens
│   └── widgets/      # Reusable components
├── theme/            # Design tokens
├── router/           # Navigation
└── main.dart         # Entry point
```

---

## 🎨 Design Philosophy

- **Calm over cluttered** — minimal UI, single primary action per screen
- **Gentle over aggressive** — soft colors, low-pressure interactions
- **Offline-first** — works without internet, no backend dependency
- **Introvert-friendly** — optional connection, no forced social features

---

## 🔒 Privacy

- **No data collection** — everything stays on your device
- **No analytics tracking** — internal analytics only (never sent anywhere)
- **No account required** — anonymous local session
- **No ads** — clean, distraction-free experience

---

## 🛠️ Development

### Prerequisites
- Flutter SDK 3.11+
- Dart 3.0+
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

---

## 📦 Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed build instructions.

**TL;DR:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔮 Future Enhancements

- [ ] Firebase backend integration (see `FIREBASE_MIGRATION.md`)
- [ ] Real-time chat with other users
- [ ] Profile pictures
- [ ] Export Brain Dump history
- [ ] Dark mode
- [ ] Customizable reminder times
- [ ] More life department categories

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow the existing code style
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

MIT License — see LICENSE file for details.

---

## 💙 Support

If Ease helps you, consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 📢 Sharing with others who might benefit

---

**Built with care for those who need a gentle space to breathe.**
