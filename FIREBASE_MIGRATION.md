# Firebase Migration Guide

The app is fully production-ready with local persistence.
When you're ready to go live with a real backend, follow these steps.

## 1. Add Firebase to the project

```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutterfire configure   # generates google-services.json + GoogleService-Info.plist
```

## 2. Initialize in main.dart

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

## 3. Swap AuthService

Replace the body of `signInAnonymously`, `signInWithEmail`, `registerWithEmail`
with the corresponding `FirebaseAuth.instance.*` calls.
The `EaseUser` model maps directly to `firebase_auth.User`.

## 4. Swap StorageService

Replace `SharedPreferences` persistence with Firestore writes:

```
/users/{uid}/profile        → UserProfile
/users/{uid}/state          → AppState (mood, easeScore, etc.)
/users/{uid}/brainDumps     → BrainDumpEntry[]
/users/{uid}/tasks          → TaskItem[]
/users/{uid}/categories     → CategoryData[]
```

## 5. Swap ChatProvider

Replace `DatabaseService` calls with Firestore real-time listeners:

```
/chats/{chatId}/messages    → ChatMessage (orderBy timestamp)
/chats/{chatId}             → ChatSession
```

Use `snapshots()` stream instead of the local `StreamController`.

## 6. Swap MatchingService pool

Replace the static `_matchPool` in `AppStateProvider.buildMatches()`
with a Firestore query:

```dart
final docs = await FirebaseFirestore.instance
    .collection('users')
    .where('onboardingComplete', isEqualTo: true)
    .where('uid', isNotEqualTo: currentUser.uid)
    .limit(20)
    .get();
```

## 7. Analytics

Replace `DatabaseService.logEvent` with `FirebaseAnalytics.instance.logEvent`.

## 8. Notifications

No changes needed — `flutter_local_notifications` works as-is.
For push notifications add `firebase_messaging`.

---

All service interfaces are already abstracted. No UI files need to change.
