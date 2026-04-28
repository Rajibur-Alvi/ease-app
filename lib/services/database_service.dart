import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/chat_models.dart';
import '../models/analytics_models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _db;

  DatabaseService._();
  factory DatabaseService() => _instance ??= DatabaseService._();

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'ease_v2.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_sessions (
        id TEXT PRIMARY KEY,
        match_id TEXT NOT NULL,
        match_name TEXT NOT NULL,
        last_activity INTEGER NOT NULL,
        last_message TEXT,
        unread_count INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status INTEGER DEFAULT 1,
        FOREIGN KEY (chat_id) REFERENCES chat_sessions(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE usage_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        meta TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_messages_chat ON chat_messages(chat_id, timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS usage_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          meta TEXT
        )
      ''');
    }
  }

  // ── Chat Sessions ──────────────────────────────────────────────────────────

  Future<ChatSession> upsertSession(ChatSession session) async {
    final d = await db;
    await d.insert(
      'chat_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return session;
  }

  Future<List<ChatSession>> getSessions() async {
    final d = await db;
    final rows = await d.query('chat_sessions',
        orderBy: 'last_activity DESC');
    return rows.map(ChatSession.fromMap).toList();
  }

  Future<ChatSession?> getSession(String id) async {
    final d = await db;
    final rows =
        await d.query('chat_sessions', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : ChatSession.fromMap(rows.first);
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Future<void> insertMessage(ChatMessage msg) async {
    final d = await db;
    await d.insert('chat_messages', msg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // Update session last_activity + last_message
    await d.update(
      'chat_sessions',
      {
        'last_activity': msg.timestamp.millisecondsSinceEpoch,
        'last_message': msg.text,
      },
      where: 'id = ?',
      whereArgs: [msg.chatId],
    );
  }

  Future<List<ChatMessage>> getMessages(String chatId,
      {int limit = 50, int offset = 0}) async {
    final d = await db;
    final rows = await d.query(
      'chat_messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> markMessagesRead(String chatId, String myId) async {
    final d = await db;
    await d.update(
      'chat_messages',
      {'status': MessageStatus.read.index},
      where: 'chat_id = ? AND receiver_id = ? AND status < ?',
      whereArgs: [chatId, myId, MessageStatus.read.index],
    );
    await d.update(
      'chat_sessions',
      {'unread_count': 0},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  Future<void> logEvent(UsageEvent event) async {
    final d = await db;
    await d.insert('usage_events', {
      'type': event.type,
      'timestamp': event.timestamp.millisecondsSinceEpoch,
      'meta': event.meta.toString(),
    });
  }

  Future<AnalyticsSummary> getAnalytics() async {
    final d = await db;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final totalDumps = Sqflite.firstIntValue(await d.rawQuery(
            "SELECT COUNT(*) FROM usage_events WHERE type='brain_dump'")) ??
        0;
    final weekDumps = Sqflite.firstIntValue(await d.rawQuery(
            "SELECT COUNT(*) FROM usage_events WHERE type='brain_dump' AND timestamp > ?",
            [weekAgo.millisecondsSinceEpoch])) ??
        0;
    final matchViews = Sqflite.firstIntValue(await d.rawQuery(
            "SELECT COUNT(*) FROM usage_events WHERE type='match_view'")) ??
        0;
    final chatOpens = Sqflite.firstIntValue(await d.rawQuery(
            "SELECT COUNT(*) FROM usage_events WHERE type='chat_open'")) ??
        0;

    // Mood frequency
    final moodRows = await d.rawQuery(
        "SELECT meta, COUNT(*) as cnt FROM usage_events WHERE type='mood_check' GROUP BY meta");
    final moodFreq = <String, int>{};
    for (final row in moodRows) {
      moodFreq[row['meta'] as String] = row['cnt'] as int;
    }

    // Streak: count consecutive days with at least one brain_dump
    final streakDays = await _computeStreak(d);

    return AnalyticsSummary(
      brainDumpsTotal: totalDumps,
      brainDumpsThisWeek: weekDumps,
      moodFrequency: moodFreq,
      matchViews: matchViews,
      chatOpens: chatOpens,
      streakDays: streakDays,
    );
  }

  Future<int> _computeStreak(Database d) async {
    final rows = await d.rawQuery(
        "SELECT DISTINCT date(timestamp/1000, 'unixepoch') as day "
        "FROM usage_events WHERE type='brain_dump' ORDER BY day DESC");
    if (rows.isEmpty) return 0;
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (final row in rows) {
      final day = DateTime.parse(row['day'] as String);
      final diff = cursor
          .difference(DateTime(day.year, day.month, day.day))
          .inDays;
      if (diff <= 1) {
        streak++;
        cursor = day;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> close() async {
    final d = _db;
    if (d != null) {
      await d.close();
      _db = null;
    }
  }
}
