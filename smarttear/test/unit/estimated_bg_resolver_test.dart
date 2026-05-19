import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/analyte_value.dart';
import 'package:smarttear/domain/entities/qc_status.dart';
import 'package:smarttear/domain/entities/reading.dart';
import 'package:smarttear/domain/services/tg_bg_estimator_port.dart';
import 'package:smarttear/infrastructure/ml/estimated_bg_resolver.dart';

class _FakeTgBgEstimator implements TgBgEstimatorPort {
  _FakeTgBgEstimator(this.response);
  final double? response;
  int callCount = 0;

  @override
  double? estimateBG(double tgMmol) {
    callCount++;
    return response;
  }
}

Reading _reading({
  List<AnalyteValue>? analytes,
  String? invalidReason,
}) {
  return Reading(
    id: 1,
    userId: 'u',
    deviceId: 'dev-1',
    takenAt: DateTime(2026, 1, 1),
    sampleStatus: 'complete',
    contactDurationMs: 1500,
    qcStatus: QCStatus.valid,
    invalidReason: invalidReason,
    modelVersion: 'v1',
    rawPackageRef: 'ref-1',
    analytes: analytes ??
        const [
          AnalyteValue(analyteCode: 'TG', value: 0.5, unit: 'mmol/L'),
        ],
  );
}

void main() {
  test('BGR-001: returns stored estimatedBG when present', () {
    final fake = _FakeTgBgEstimator(99.0);
    final resolver = EstimatedBgResolver(fake);
    final r = _reading(analytes: const [
      AnalyteValue(
          analyteCode: 'TG', value: 0.5, unit: 'mmol/L', estimatedBG: 6.2),
    ]);
    expect(resolver.forReading(r), 6.2);
    expect(fake.callCount, 0);
  });

  test('BGR-002: falls back to model when stored is null', () {
    final fake = _FakeTgBgEstimator(7.5);
    final resolver = EstimatedBgResolver(fake);
    final r = _reading();
    expect(resolver.forReading(r), 7.5);
    expect(fake.callCount, 1);
  });

  test('BGR-003: returns null when reading has no TG analyte', () {
    final fake = _FakeTgBgEstimator(7.5);
    final resolver = EstimatedBgResolver(fake);
    final r = _reading(analytes: const [
      AnalyteValue(analyteCode: 'Na', value: 130.0, unit: 'mEq/L'),
    ]);
    expect(resolver.forReading(r), isNull);
    expect(fake.callCount, 0);
  });

  test('BGR-004: parallelTo preserves length and null slots', () {
    final fake = _FakeTgBgEstimator(null); // simulate "no value"
    final resolver = EstimatedBgResolver(fake);
    final withTg = _reading();
    final withoutTg = _reading(analytes: const [
      AnalyteValue(analyteCode: 'Na', value: 130.0, unit: 'mEq/L'),
    ]);
    final out = resolver.parallelTo([withTg, withoutTg]);
    expect(out.length, 2);
    expect(out[0], isNull);
    expect(out[1], isNull);
  });

  test('BGR-005: forReadings drops null entries', () {
    final fake = _FakeTgBgEstimator(8.1);
    final resolver = EstimatedBgResolver(fake);
    final withTg = _reading();
    final withoutTg = _reading(analytes: const [
      AnalyteValue(analyteCode: 'Na', value: 130.0, unit: 'mEq/L'),
    ]);
    final out = resolver.forReadings([withTg, withoutTg, withTg]);
    expect(out.length, 2);
    expect(out, [8.1, 8.1]);
  });
}
