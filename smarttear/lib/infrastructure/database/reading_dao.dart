import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'reading_dao.g.dart';

@DriftAccessor(tables: [Readings, ReadingAnalytes, Notes])
class ReadingDao extends DatabaseAccessor<AppDatabase> with _$ReadingDaoMixin {
  ReadingDao(super.db);

  Future<int> insertReading(ReadingsCompanion r) {
    // Caller supplies userId; table enforces per-row user ownership.
    return into(readings).insert(r);
  }

  Future<void> insertReadingAnalytes(List<ReadingAnalytesCompanion> values) async {
    // Per-user rows must carry userId in each companion.
    await batch((b) => b.insertAll(readingAnalytes, values));
  }

  Future<List<Reading>> getReadingsByUser(int userId, {int limit = 50}) {
    return (select(readings)
          ..where((r) => r.userId.equals(userId))
          ..orderBy([(r) => OrderingTerm.desc(r.takenAt)])
          ..limit(limit))
        .get();
  }

  Future<Reading?> getReadingById(int id, int userId) {
    return (select(readings)
          ..where((r) => r.id.equals(id) & r.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> updateNote(int readingId, String note) async {
    // NOTE: No userId parameter is provided. We scope writes by deriving the
    // owning userId from the reading row, then only writing notes for that user.
    final readingRow =
        await (select(readings)..where((r) => r.id.equals(readingId)))
            .getSingleOrNull();
    if (readingRow == null) return;

    final userId = readingRow.userId;

    await transaction(() async {
      final existing = await (select(notes)
            ..where((n) => n.readingId.equals(readingId) & n.userId.equals(userId))
            ..limit(1))
          .getSingleOrNull();

      if (existing == null) {
        await into(notes).insert(
          NotesCompanion.insert(
            userId: userId,
            readingId: readingId,
            content: note,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await (update(notes)
              ..where((n) =>
                  n.id.equals(existing.id) & n.userId.equals(userId)))
            .write(NotesCompanion(content: Value(note)));
      }
    });
  }

  Future<List<Reading>> getReadingsByDateRange(
    int userId,
    DateTime from,
    DateTime to,
  ) {
    return (select(readings)
          ..where((r) =>
              r.userId.equals(userId) &
              r.takenAt.isBiggerOrEqualValue(from) &
              r.takenAt.isSmallerOrEqualValue(to))
          ..orderBy([(r) => OrderingTerm.asc(r.takenAt)]))
        .get();
  }

  Future<void> deleteReading(int id, int userId) async {
    await transaction(() async {
      // Delete dependent notes for this user+reading.
      await (delete(notes)
            ..where((n) => n.userId.equals(userId) & n.readingId.equals(id)))
          .go();

      // Delete analytes for this user+reading.
      await (delete(readingAnalytes)
            ..where((ra) =>
                ra.userId.equals(userId) & ra.readingId.equals(id)))
          .go();

      // Finally delete the reading (must match userId).
      await (delete(readings)
            ..where((r) => r.userId.equals(userId) & r.id.equals(id)))
          .go();
    });
  }
}

