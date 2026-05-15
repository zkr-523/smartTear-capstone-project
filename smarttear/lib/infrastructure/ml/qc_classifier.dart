import '../../domain/entities/analyte_value.dart';
import '../../domain/entities/data_package.dart';
import '../../domain/entities/qc_status.dart';
import 'qc_thresholds.dart';

class QCResult {
  const QCResult({required this.status, this.reason});

  final QCStatus status;
  final String? reason;
}

class QCClassifier {
  const QCClassifier();

  QCResult classify(
    DataPackage package,
    List<AnalyteValue> analytes,
    QCThresholds thresholds,
  ) {
    // Rule 1 — Contact duration
    final contactDurationMs = package.contactDurationMs;
    if (contactDurationMs != null &&
        contactDurationMs < thresholds.minContactDurationMs) {
      return const QCResult(
        status: QCStatus.invalid,
        reason: 'Contact time too short — hold tip against eye longer',
      );
    }

    // Rule 2 — Signal variance (channels 0..4)
    final channels = package.rawChannels;
    if (channels.length >= 5) {
      final v = _variance(channels.sublist(0, 5));
      if (v < thresholds.minChannelVariance) {
        return const QCResult(
          status: QCStatus.invalid,
          reason: 'Weak signal — insufficient tear sample volume',
        );
      }
    }

    // Rule 3 — Glucose plausibility
    final glucose = analytes
        .where((a) => a.analyteCode == 'TG')
        .map((a) => a.value)
        .firstOrNull;
    if (glucose != null &&
        (glucose < thresholds.glucoseMin || glucose > thresholds.glucoseMax)) {
      return const QCResult(
        status: QCStatus.invalid,
        reason: 'Analyte value outside expected range — retake recommended',
      );
    }

    return const QCResult(status: QCStatus.valid);
  }
}

double _variance(List<double> xs) {
  if (xs.isEmpty) return 0.0;
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  var sumSq = 0.0;
  for (final x in xs) {
    final d = x - mean;
    sumSq += d * d;
  }
  return sumSq / xs.length;
}

extension on Iterable<double> {
  double? get firstOrNull => isEmpty ? null : first;
}

