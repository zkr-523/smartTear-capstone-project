import '../../domain/entities/reading.dart';

/// Maps tear glucose (TG) to an estimated blood-glucose–style value using
/// lag (which historical tear sample to use) and linear scale/offset.
class TGtoBGMapper {
  const TGtoBGMapper();

  double map(double tearGlucose, {double scale = 18.0, double offset = 0.0}) {
    return (tearGlucose * scale) + offset;
  }

  /// Uses the tear glucose from the historical reading whose [Reading.takenAt]
  /// is closest to `readingTime - lagSeconds`, then applies scale and offset.
  ///
  /// [sortedReadings] must be sorted by [Reading.takenAt] ascending.
  double mapWithLag(
    double tearGlucose,
    DateTime readingTime,
    List<Reading> sortedReadings, {
    double lagSeconds = 600,
    double scale = 18.0,
    double offset = 0.0,
  }) {
    if (sortedReadings.isEmpty) {
      return (tearGlucose * scale) + offset;
    }

    final target = readingTime.subtract(
      Duration(milliseconds: (lagSeconds * 1000).round()),
    );

    Reading? closest;
    late int bestAbsMs;
    for (var i = 0; i < sortedReadings.length; i++) {
      final r = sortedReadings[i];
      final d = (r.takenAt.millisecondsSinceEpoch - target.millisecondsSinceEpoch)
          .abs();
      if (i == 0 || d < bestAbsMs) {
        bestAbsMs = d;
        closest = r;
      }
    }

    final sourceTearGlucose = closest?.glucose?.value ?? tearGlucose;
    return (sourceTearGlucose * scale) + offset;
  }
}
