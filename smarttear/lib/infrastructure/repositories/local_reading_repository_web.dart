import 'package:collection/collection.dart';

import '../../domain/entities/data_package.dart';
import '../../domain/entities/reading.dart';
import '../../domain/repositories/reading_repository_port.dart';

/// Web: no `dart:io` — keep raw packages and readings in memory only.
class LocalReadingRepository implements ReadingRepositoryPort {
  LocalReadingRepository();

  final List<Reading> _readings = <Reading>[];

  List<Reading> get readings => List.unmodifiable(_readings);

  @override
  Future<String> saveRawPackage(DataPackage package) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    return id;
  }

  @override
  Future<void> saveReading(Reading reading) async {
    _readings.insert(0, reading);
  }

  @override
  Future<Reading?> getReadingByRef(String readingId) async {
    return _readings
        .where((r) => r.rawPackageRef == readingId)
        .firstOrNull;
  }

  @override
  Future<List<Reading>> latestReadings({int limit = 10}) async {
    if (_readings.isEmpty) return const <Reading>[];
    return _readings.take(limit).toList(growable: false);
  }

  @override
  Future<List<Reading>> listReadingsForUser(String userId, {int limit = 500}) async {
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
    final i = _readings.indexWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
    if (i < 0) return;
    _readings[i] = _readings[i].copyWith(note: note);
  }

  @override
  Future<void> deleteReading(String readingRef, String userId) async {
    _readings.removeWhere(
      (r) => r.rawPackageRef == readingRef && r.userId == userId,
    );
  }

  @override
  Future<void> mergeReadings(List<Reading> readings, String userId) async {
    final seen = _readings.map((r) => r.rawPackageRef).toSet();
    for (final r in readings) {
      if (r.userId != userId) continue;
      if (seen.contains(r.rawPackageRef)) continue;
      _readings.add(r);
      seen.add(r.rawPackageRef);
    }
    _readings.sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }
}
