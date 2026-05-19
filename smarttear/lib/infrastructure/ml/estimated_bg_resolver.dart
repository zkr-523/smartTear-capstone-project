import '../../domain/entities/reading.dart';
import '../../domain/services/tg_bg_estimator_port.dart';

/// Resolves estimated blood glucose (mmol/L) from stored value or ML model.
class EstimatedBgResolver {
  EstimatedBgResolver(this._model);

  final TgBgEstimatorPort _model;

  double? forReading(Reading reading) {
    final glucose = reading.glucose;
    if (glucose == null) return null;
    final stored = glucose.estimatedBG;
    if (stored != null && stored.isFinite) return stored;
    return _model.estimateBG(glucose.value);
  }

  List<double> forReadings(List<Reading> readings) {
    final out = <double>[];
    for (final r in readings) {
      final bg = forReading(r);
      if (bg != null) out.add(bg);
    }
    return out;
  }

  /// One value per reading (null when TG missing).
  List<double?> parallelTo(List<Reading> readings) {
    return readings.map(forReading).toList(growable: false);
  }
}
