import '../entities/data_package.dart';
import '../entities/chat_message_view.dart';
import '../entities/reading.dart';

abstract class ReadingRepositoryPort {
  /// Persist the raw package before processing to prevent data loss.
  /// Returns a stable reference to the stored package.
  Future<String> saveRawPackage(DataPackage package);

  Future<void> saveReading(Reading reading);

  /// Load a reading using the stable reference used in routes (e.g. rawPackageRef).
  Future<Reading?> getReadingByRef(String readingId);

  /// Returns most-recent-first readings.
  Future<List<Reading>> latestReadings({int limit = 10});

  /// All readings for this user, newest first.
  Future<List<Reading>> listReadingsForUser(String userId, {int limit = 500});

  Future<void> updateReadingNote(
    String readingRef,
    String userId,
    String? note,
  );

  Future<void> deleteReading(String readingRef, String userId);

  /// Merge imported readings (same userId only); skips duplicates by [rawPackageRef].
  Future<void> mergeReadings(List<Reading> readings, String userId);

  /// Chat persistence. Messages are scoped by optional [readingId].
  /// Use `readingId == null` for general chat.
  Future<List<ChatMessageView>> loadChatMessages({
    required String userId,
    required int? readingId,
    int limit = 200,
  });

  Future<void> saveChatMessage({
    required String userId,
    required int? readingId,
    required String role, // "user" | "assistant"
    required String text,
    DateTime? createdAt,
  });
}

