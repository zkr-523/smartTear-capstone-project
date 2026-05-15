import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/chat_message_view.dart';
import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';

/// Native/desktop: persist under app documents (best-effort).
class LocalReadingRepository implements ReadingRepositoryPort {
  LocalReadingRepository();

  final List<Reading> _readings = <Reading>[];
  final Map<String, Map<int?, List<ChatMessageView>>> _chat =
      <String, Map<int?, List<ChatMessageView>>>{};
  var _chatAutoId = 1;

  List<Reading> get readings => List.unmodifiable(_readings);

  @override
  Future<String> saveRawPackage(DataPackage package) async {
    final dir = await _rawDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final file = File('${dir.path}${Platform.pathSeparator}$id.json');
    await file.writeAsString(jsonEncode(package.toJson()));
    return id;
  }

  @override
  Future<void> saveReading(Reading reading) async {
    _readings.insert(0, reading);
    try {
      final dir = await _readingsDir();
      final id = reading.rawPackageRef;
      final file = File('${dir.path}${Platform.pathSeparator}$id.json');
      await file.writeAsString(jsonEncode(reading.toJson()));
    } catch (_) {}
  }

  @override
  Future<Reading?> getReadingByRef(String readingId) async {
    await _ensureDiskLoadedIntoMemory();
    final inMemory =
        _readings.where((r) => r.rawPackageRef == readingId).firstOrNull;
    if (inMemory != null) return inMemory;

    final asInt = int.tryParse(readingId);
    if (asInt != null) {
      final byId = _readings.where((r) => r.id == asInt).firstOrNull;
      if (byId != null) return byId;
    }

    try {
      final dir = await _readingsDir();
      final file = File('${dir.path}${Platform.pathSeparator}$readingId.json');
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final r = Reading.fromJson(decoded);
      _readings.insert(0, r);
      return r;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Reading>> latestReadings({int limit = 10}) async {
    await _ensureDiskLoadedIntoMemory();
    if (_readings.isEmpty) return const <Reading>[];
    return _readings.take(limit).toList(growable: false);
  }

  @override
  Future<List<Reading>> listReadingsForUser(String userId, {int limit = 500}) async {
    await _ensureDiskLoadedIntoMemory();
    final list = _readings.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return list.take(limit).toList(growable: false);
  }

  Future<void> _ensureDiskLoadedIntoMemory() async {
    try {
      final dir = await _readingsDir();
      if (!await dir.exists()) return;
      final seen = _readings.map((r) => r.rawPackageRef).toSet();
      await for (final entity in dir.list()) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final decoded = jsonDecode(await entity.readAsString());
          if (decoded is! Map<String, dynamic>) continue;
          final r = Reading.fromJson(decoded);
          if (seen.contains(r.rawPackageRef)) continue;
          _readings.add(r);
          seen.add(r.rawPackageRef);
        } catch (_) {}
      }
      _readings.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    } catch (_) {}
  }

  @override
  Future<void> updateReadingNote(
    String readingRef,
    String userId,
    String? note,
  ) async {
    final i = _readings.indexWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
    if (i < 0) return;
    _readings[i] = _readings[i].copyWith(note: note);
    try {
      final dir = await _readingsDir();
      final file = File('${dir.path}${Platform.pathSeparator}$readingRef.json');
      await file.writeAsString(jsonEncode(_readings[i].toJson()));
    } catch (_) {}
  }

  @override
  Future<void> deleteReading(String readingRef, String userId) async {
    _readings.removeWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
    try {
      final dir = await _readingsDir();
      final file = File('${dir.path}${Platform.pathSeparator}$readingRef.json');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  @override
  Future<void> mergeReadings(List<Reading> readings, String userId) async {
    final seen = _readings.map((r) => r.rawPackageRef).toSet();
    for (final r in readings) {
      if (r.userId != userId) continue;
      if (seen.contains(r.rawPackageRef)) continue;
      _readings.add(r);
      seen.add(r.rawPackageRef);
      try {
        final dir = await _readingsDir();
        final file = File('${dir.path}${Platform.pathSeparator}${r.rawPackageRef}.json');
        await file.writeAsString(jsonEncode(r.toJson()));
      } catch (_) {}
    }
    _readings.sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  @override
  Future<List<ChatMessageView>> loadChatMessages({
    required String userId,
    required int? readingId,
    int limit = 200,
  }) async {
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
  }

  Future<Directory> _rawDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}${Platform.pathSeparator}raw_packages');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _readingsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}${Platform.pathSeparator}readings');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
