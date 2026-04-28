import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import '../models/models.dart';
import 'auth_service.dart';
import 'database_service.dart';

/// Manages real-time chat state.
/// Architecture is stream-based so swapping to Firestore snapshots
/// requires only replacing the StreamController with a Firestore listener.
class ChatProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  List<ChatSession> _sessions = [];
  List<ChatMessage> _activeMessages = [];
  String? _activeChatId;
  bool _isTyping = false;
  Timer? _typingTimer;
  bool _isLoading = false;

  // Stream controller — replace with Firestore snapshots for real-time
  final _messageStreamController =
      StreamController<List<ChatMessage>>.broadcast();

  List<ChatSession> get sessions => _sessions;
  List<ChatMessage> get activeMessages => _activeMessages;
  String? get activeChatId => _activeChatId;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  Stream<List<ChatMessage>> get messageStream =>
      _messageStreamController.stream;

  Future<void> loadSessions() async {
    _sessions = await _db.getSessions();
    notifyListeners();
  }

  /// Open or create a chat session with a match.
  Future<ChatSession> openChat(CompanionMatch match) async {
    final chatId = 'chat_${_auth.currentUser?.uid ?? 'local'}_${match.id}';
    var session = await _db.getSession(chatId);
    if (session == null) {
      session = ChatSession(
        id: chatId,
        matchId: match.id,
        matchName: match.name,
        lastActivity: DateTime.now(),
      );
      await _db.upsertSession(session);
    }
    _activeChatId = chatId;
    await _loadMessages(chatId);
    await _db.markMessagesRead(chatId, _auth.currentUser?.uid ?? 'local');
    await loadSessions();
    return session;
  }

  Future<void> _loadMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    _activeMessages = await _db.getMessages(chatId);
    _messageStreamController.add(_activeMessages);
    _isLoading = false;
    notifyListeners();
  }

  /// Send a message and trigger an auto-reply.
  Future<void> sendMessage(String text, CompanionMatch match) async {
    if (text.trim().isEmpty || _activeChatId == null) return;
    final myId = _auth.currentUser?.uid ?? 'local';

    final msg = ChatMessage(
      id: ChatMessage.newId(),
      chatId: _activeChatId!,
      senderId: myId,
      receiverId: match.id,
      text: text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    await _db.insertMessage(msg);
    _activeMessages = [..._activeMessages, msg];
    _messageStreamController.add(_activeMessages);
    notifyListeners();

    // Simulate typing indicator then auto-reply
    _showTyping();
    await Future.delayed(const Duration(milliseconds: 1400));
    _hideTyping();

    final reply = ChatMessage(
      id: ChatMessage.newId(),
      chatId: _activeChatId!,
      senderId: match.id,
      receiverId: myId,
      text: _autoReply(text, match),
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );
    await _db.insertMessage(reply);
    _activeMessages = [..._activeMessages, reply];
    _messageStreamController.add(_activeMessages);
    await loadSessions();
    notifyListeners();
  }

  void _showTyping() {
    _isTyping = true;
    notifyListeners();
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _hideTyping);
  }

  void _hideTyping() {
    _isTyping = false;
    notifyListeners();
  }

  void closeChat() {
    _activeChatId = null;
    _activeMessages = [];
    _isTyping = false;
    notifyListeners();
  }

  String _autoReply(String input, CompanionMatch match) {
    final lower = input.toLowerCase();
    if (lower.contains('stress') || lower.contains('overwhelm')) {
      return 'I totally get that. Sometimes just naming it out loud helps. 💙';
    }
    if (lower.contains('work') || lower.contains('job') ||
        lower.contains('deadline')) {
      return 'Work pressure is real. What\'s the one thing you can let go of today?';
    }
    if (lower.contains('lonely') || lower.contains('alone')) {
      return 'You\'re not alone in this. I\'m here. 🌿';
    }
    if (lower.contains('hi') || lower.contains('hello') ||
        lower.contains('hey')) {
      return 'Hey ${match.name.split(' ').first}! Glad you reached out. How are you really doing?';
    }
    if (lower.contains('tired') || lower.contains('exhausted')) {
      return 'Rest is productive too. Be gentle with yourself today.';
    }
    if (lower.contains('money') || lower.contains('finance')) {
      return 'Financial stress is heavy. One small step at a time — what\'s the most urgent thing?';
    }
    final shared = match.interests.isNotEmpty ? match.interests.first : null;
    if (shared != null && lower.contains(shared.toLowerCase())) {
      return 'Oh I love $shared too! Tell me more about that.';
    }
    return 'Thanks for sharing that. I\'m here to listen. 🌿';
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageStreamController.close();
    super.dispose();
  }
}
