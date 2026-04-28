import 'package:uuid/uuid.dart';

enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
        id: id,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: timestamp,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'status': status.index,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['id'] as String,
        chatId: m['chat_id'] as String,
        senderId: m['sender_id'] as String,
        receiverId: m['receiver_id'] as String,
        text: m['text'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
        status: MessageStatus.values[m['status'] as int? ?? 1],
      );

  static String newId() => const Uuid().v4();
}

class ChatSession {
  final String id;
  final String matchId;
  final String matchName;
  final DateTime lastActivity;
  final String? lastMessage;
  final int unreadCount;

  ChatSession({
    required this.id,
    required this.matchId,
    required this.matchName,
    required this.lastActivity,
    this.lastMessage,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'match_id': matchId,
        'match_name': matchName,
        'last_activity': lastActivity.millisecondsSinceEpoch,
        'last_message': lastMessage,
        'unread_count': unreadCount,
      };

  factory ChatSession.fromMap(Map<String, dynamic> m) => ChatSession(
        id: m['id'] as String,
        matchId: m['match_id'] as String,
        matchName: m['match_name'] as String,
        lastActivity: DateTime.fromMillisecondsSinceEpoch(
            m['last_activity'] as int),
        lastMessage: m['last_message'] as String?,
        unreadCount: m['unread_count'] as int? ?? 0,
      );
}
