import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Represents a signed-in user session.
class EaseUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? avatarUrl;

  const EaseUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.avatarUrl,
  });

  EaseUser copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
  }) =>
      EaseUser(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory EaseUser.fromJson(Map<String, dynamic> j) => EaseUser(
        uid: j['uid'] as String,
        displayName: j['displayName'] as String? ?? 'Friend',
        email: j['email'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

/// Local-first auth service.
/// Swap the implementation body for Firebase Auth calls when ready.
class AuthService {
  static const _sessionKey = 'ease_session_v1';
  static AuthService? _instance;
  AuthService._();
  factory AuthService() => _instance ??= AuthService._();

  EaseUser? _current;
  EaseUser? get currentUser => _current;
  bool get isSignedIn => _current != null;

  /// Restore session from local storage on app start.
  Future<EaseUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      _current = EaseUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _current;
    } catch (_) {
      return null;
    }
  }

  /// Create or restore an anonymous local session.
  Future<EaseUser> signInAnonymously({required String displayName}) async {
    final prefs = await SharedPreferences.getInstance();
    // Reuse existing uid if present
    final existing = prefs.getString(_sessionKey);
    String uid;
    if (existing != null) {
      try {
        uid = (jsonDecode(existing) as Map<String, dynamic>)['uid'] as String;
      } catch (_) {
        uid = const Uuid().v4();
      }
    } else {
      uid = const Uuid().v4();
    }
    _current = EaseUser(uid: uid, displayName: displayName);
    await prefs.setString(_sessionKey, jsonEncode(_current!.toJson()));
    return _current!;
  }

  /// Sign in with email + password (stub — wire to Firebase Auth).
  Future<EaseUser> signInWithEmail(String email, String password) async {
    // TODO: replace with FirebaseAuth.instance.signInWithEmailAndPassword
    final uid = const Uuid().v5(Namespace.url.value, email);
    _current = EaseUser(uid: uid, displayName: email.split('@').first, email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(_current!.toJson()));
    return _current!;
  }

  /// Register with email + password (stub — wire to Firebase Auth).
  Future<EaseUser> registerWithEmail(
      String email, String password, String displayName) async {
    // TODO: replace with FirebaseAuth.instance.createUserWithEmailAndPassword
    final uid = const Uuid().v5(Namespace.url.value, email);
    _current = EaseUser(
        uid: uid, displayName: displayName, email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(_current!.toJson()));
    return _current!;
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (_current == null) return;
    _current = _current!.copyWith(
        displayName: displayName, avatarUrl: avatarUrl);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(_current!.toJson()));
  }

  Future<void> signOut() async {
    _current = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
