import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_message_view.dart';
import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';

const String _kPrefsReadings = 'smarttear_readings_v1';
const String _kPrefsChat = 'smarttear_chat_v1';
const String _kPrefsChatAutoId = 'smarttear_chat_autoid_v1';

/// Web: no `dart:io` — persist readings and chat in [SharedPreferences] so
/// refresh/deep links to `/results/:id` still resolve after reload.
class LocalReadingRepository implements ReadingRepositoryPort {
  LocalReadingRepository();

  final List<Reading> _readings = <Reading>[];
  final Map<String, Map<int?, List<ChatMessageView>>> _chat =
      <String, Map<int?, List<ChatMessageView>>>{};
  var _chatAutoId = 1;

  var _hydrated = false;
  Future<void>? _hydrateFuture;

  List<Reading> get readings => List.unmodifiable(_readings);

  Future<void> _ensureHydrated() {
    if (_hydrated) return Future.value();
    _hydrateFuture ??= _hydrate();
    return _hydrateFuture!;
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawReadings = prefs.getString(_kPrefsReadings);
      if (rawReadings != null && rawReadings.isNotEmpty) {
        final decoded = jsonDecode(rawReadings);
        if (decoded is List<dynamic>) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _readings.add(Reading.fromJson(item));
            }
          }
          _readings.sort((a, b) => b.takenAt.compareTo(a.takenAt));
        }
      }

      final rawChat = prefs.getString(_kPrefsChat);
      if (rawChat != null && rawChat.isNotEmpty) {
        final decoded = jsonDecode(rawChat);
        if (decoded is Map<String, dynamic>) {
          for (final userEntry in decoded.entries) {
            final uid = userEntry.key;
            final byReading = userEntry.value;
            if (byReading is! Map<String, dynamic>) continue;
            final map = <int?, List<ChatMessageView>>{};
            for (final re in byReading.entries) {
              final int? rid = re.key == '_' ? null : int.tryParse(re.key);
              final list = re.value;
              if (list is! List<dynamic>) continue;
              final msgs = <ChatMessageView>[];
              for (final m in list) {
                if (m is! Map<String, dynamic>) continue;
                final idRaw = m['id'];
                final id = idRaw is int
                    ? idRaw
                    : (idRaw is num ? idRaw.toInt() : null);
                final role = m['role'];
                final text = m['text'];
                final created = m['createdAt'];
                if (id == null || role is! String || text is! String) continue;
                DateTime at;
                if (created is String) {
                  at = DateTime.tryParse(created) ?? DateTime.now();
                } else {
                  at = DateTime.now();
                }
                msgs.add(
                  ChatMessageView(id: id, role: role, text: text, createdAt: at),
                );
              }
              map[rid] = msgs;
            }
            if (map.isNotEmpty) _chat[uid] = map;
          }
        }
      }

      _chatAutoId = prefs.getInt(_kPrefsChatAutoId) ?? 1;
      var maxId = _chatAutoId - 1;
      for (final byUser in _chat.values) {
        for (final list in byUser.values) {
          for (final m in list) {
            if (m.id > maxId) maxId = m.id;
          }
        }
      }
      if (maxId >= _chatAutoId) _chatAutoId = maxId + 1;
    } catch (_) {
      // Keep in-memory state; persistence is best-effort.
    }
    _hydrated = true;
  }

  Future<void> _persistReadings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_readings.map((r) => r.toJson()).toList(growable: false));
      await prefs.setString(_kPrefsReadings, encoded);
    } catch (_) {}
  }

  Future<void> _persistChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outer = <String, dynamic>{};
      for (final userEntry in _chat.entries) {
        final inner = <String, dynamic>{};
        for (final re in userEntry.value.entries) {
          final key = re.key == null ? '_' : re.key.toString();
          inner[key] = re.value
              .map(
                (m) => <String, dynamic>{
                  'id': m.id,
                  'role': m.role,
                  'text': m.text,
                  'createdAt': m.createdAt.toIso8601String(),
                },
              )
              .toList(growable: false);
        }
        outer[userEntry.key] = inner;
      }
      await prefs.setString(_kPrefsChat, jsonEncode(outer));
      await prefs.setInt(_kPrefsChatAutoId, _chatAutoId);
    } catch (_) {}
  }

  @override
  Future<String> saveRawPackage(DataPackage package) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    return id;
  }

  @override
  Future<void> saveReading(Reading reading) async {
    await _ensureHydrated();
    _readings.removeWhere(
      (r) =>
          r.rawPackageRef == reading.rawPackageRef && r.userId == reading.userId,
    );
    _readings.insert(0, reading);
    await _persistReadings();
  }

  @override
  Future<Reading?> getReadingByRef(String readingId) async {
    await _ensureHydrated();
    final byRef =
        _readings.where((r) => r.rawPackageRef == readingId).firstOrNull;
    if (byRef != null) return byRef;
    final asInt = int.tryParse(readingId);
    if (asInt == null) return null;
    return _readings.where((r) => r.id == asInt).firstOrNull;
  }

  @override
  Future<List<Reading>> latestReadings({int limit = 10}) async {
    await _ensureHydrated();
    if (_readings.isEmpty) return const <Reading>[];
    return _readings.take(limit).toList(growable: false);
  }

  @override
  Future<List<Reading>> listReadingsForUser(String userId, {int limit = 500}) async {
    await _ensureHydrated();
    final list = _readings.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return list.take(limit).toList(growable: false);
  }

  @override
  Future<void> updateReadingNote(
    String readingRef,
    String userId,
    String? note,
  ) async {
    await _ensureHydrated();
    final i = _readings.indexWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
    if (i < 0) return;
    _readings[i] = _readings[i].copyWith(note: note);
    await _persistReadings();
  }

  @override
  Future<void> deleteReading(String readingRef, String userId) async {
    await _ensureHydrated();
    _readings.removeWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
    await _persistReadings();
  }

  @override
  Future<void> mergeReadings(List<Reading> readings, String userId) async {
    await _ensureHydrated();
    final seen = _readings.map((r) => r.rawPackageRef).toSet();
    for (final r in readings) {
      if (r.userId != userId) continue;
      if (seen.contains(r.rawPackageRef)) continue;
      _readings.add(r);
      seen.add(r.rawPackageRef);
    }
    _readings.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    await _persistReadings();
  }

  @override
  Future<List<ChatMessageView>> loadChatMessages({
    required String userId,
    required int? readingId,
    int limit = 200,
  }) async {
    await _ensureHydrated();
    final byUser = _chat[userId];
    if (byUser == null) return const <ChatMessageView>[];
    final list = byUser[readingId] ?? const <ChatMessageView>[];
    if (list.length <= limit) return List<ChatMessageView>.unmodifiable(list);
    return List<ChatMessageView>.unmodifiable(list.sublist(list.length - limit));
  }

  @override
  Future<void> saveChatMessage({
    required String userId,
    required int? readingId,
    required String role,
    required String text,
    DateTime? createdAt,
  }) async {
    await _ensureHydrated();
    final byUser = _chat.putIfAbsent(
      userId,
      () => <int?, List<ChatMessageView>>{},
    );
    final list = byUser.putIfAbsent(readingId, () => <ChatMessageView>[]);
    list.add(
      ChatMessageView(
        id: _chatAutoId++,
        role: role,
        text: text,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
    await _persistChat();
  }
}
