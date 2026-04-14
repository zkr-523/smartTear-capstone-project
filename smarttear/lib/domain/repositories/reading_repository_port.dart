import '../entities/data_package.dart';
import '../entities/reading.dart';

abstract class ReadingRepositoryPort {
  /// Persist the raw package before processing to prevent data loss.
  /// Returns a stable reference to the stored package.
  Future<String> saveRawPackage(DataPackage package);

  /// Persists [reading] and returns the assigned row id (for navigation, etc.).
  Future<int> saveReading(Reading reading);
}

