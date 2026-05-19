import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/analyte_value.dart';
import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/domain/entities/qc_status.dart';
import 'package:smarttear/infrastructure/ml/qc_classifier.dart';
import 'package:smarttear/infrastructure/ml/qc_thresholds.dart';

DataPackage _pkg({
  int? contactDurationMs = 1500,
  List<double>? rawChannels,
}) {
  // Default channels: varied so variance rule passes.
  return DataPackage(
    id: 'pkg-1',
    deviceId: 'dev-1',
    timestamp: DateTime(2026, 1, 1),
    schemaVersion: 1,
    sampleStatus: 'complete',
    contactDurationMs: contactDurationMs,
    rawChannels: rawChannels ??
        const [0.1, 0.3, 0.5, 0.7, 0.9, 0.5, 0.5, 0.5],
  );
}

QCThresholds _thr() {
  return QCThresholds.fromJson(<String, Object>{
    'min_contact_duration_ms': 500,
    'min_channel_variance': 0.001,
    'glucose_min': 0.1,
    'glucose_max': 0.95,
    'schema_version': 1,
  });
}

AnalyteValue _tg(double v) =>
    AnalyteValue(analyteCode: 'TG', value: v, unit: 'mmol/L');

void main() {
  const qc = QCClassifier();

  test('QC-001: valid when all rules pass', () {
    final r = qc.classify(_pkg(), [_tg(0.5)], _thr());
    expect(r.status, QCStatus.valid);
    expect(r.reason, isNull);
  });

  test('QC-002: short contact duration triggers invalid with "Contact time too short"', () {
    final r = qc.classify(_pkg(contactDurationMs: 100), [_tg(0.5)], _thr());
    expect(r.status, QCStatus.invalid);
    expect(r.reason, contains('Contact time too short'));
  });

  test('QC-003: contact equal to threshold passes', () {
    final r = qc.classify(_pkg(contactDurationMs: 500), [_tg(0.5)], _thr());
    expect(r.status, QCStatus.valid);
  });

  test('QC-004: low variance on channels 0..4 triggers invalid with "Weak signal"', () {
    final r = qc.classify(
      _pkg(rawChannels: const [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]),
      [_tg(0.5)],
      _thr(),
    );
    expect(r.status, QCStatus.invalid);
    expect(r.reason, contains('Weak signal'));
  });

  test('QC-005: glucose above glucoseMax triggers invalid', () {
    final r = qc.classify(_pkg(), [_tg(2.0)], _thr());
    expect(r.status, QCStatus.invalid);
    expect(r.reason, contains('outside expected range'));
  });

  test('QC-006: glucose below glucoseMin triggers invalid', () {
    final r = qc.classify(_pkg(), [_tg(0.01)], _thr());
    expect(r.status, QCStatus.invalid);
    expect(r.reason, contains('outside expected range'));
  });

  test('QC-007: missing contact duration does not trigger the contact rule', () {
    final r = qc.classify(_pkg(contactDurationMs: null), [_tg(0.5)], _thr());
    expect(r.status, QCStatus.valid);
  });

  test('QC-008: empty analyte list skips glucose rule and remains valid', () {
    final r = qc.classify(_pkg(), <AnalyteValue>[], _thr());
    expect(r.status, QCStatus.valid);
  });

  test('QC-009: contact rule fires before glucose rule', () {
    final r = qc.classify(
      _pkg(contactDurationMs: 100),
      [_tg(99.0)],
      _thr(),
    );
    expect(r.status, QCStatus.invalid);
    expect(r.reason, contains('Contact time too short'));
  });
}
