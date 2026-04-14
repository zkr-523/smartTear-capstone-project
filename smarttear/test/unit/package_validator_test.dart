import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/infrastructure/ml/package_validator.dart';
import 'package:smarttear/infrastructure/ml/qc_thresholds.dart';

DataPackage _basePackage({
  String deviceId = 'dev-1',
  int schemaVersion = 1,
  String sampleStatus = 'complete',
  List<double>? rawChannels,
}) {
  return DataPackage(
    id: 'pkg-1',
    deviceId: deviceId,
    timestamp: DateTime(2026, 1, 1),
    schemaVersion: schemaVersion,
    sampleStatus: sampleStatus,
    contactDurationMs: 600,
    rawChannels: rawChannels ?? List<double>.filled(8, 0.5),
  );
}

QCThresholds _thresholds({int schemaVersion = 1}) {
  return QCThresholds.fromJson(<String, Object>{
    'min_contact_duration_ms': 500,
    'min_channel_variance': 0.001,
    'glucose_min': 0.1,
    'glucose_max': 0.95,
    'schema_version': schemaVersion,
  });
}

void main() {
  const validator = PackageValidator();

  test('Rule 1: fails when rawChannels length != 8', () {
    final pkg = _basePackage(rawChannels: [0.5, 0.5]);
    final result = validator.validate(pkg, _thresholds());

    expect(result, isA<ValidationFailure>());
    expect((result as ValidationFailure).reason,
        'Corrupt packet: expected 8 channels');
  });

  test('Rule 2: fails when sampleStatus == "failed"', () {
    final pkg = _basePackage(sampleStatus: 'failed');
    final result = validator.validate(pkg, _thresholds());

    expect(result, isA<ValidationFailure>());
    expect((result as ValidationFailure).reason,
        'Device reported sample failure');
  });

  test('Rule 3: fails when any channel value out of range', () {
    final pkg = _basePackage(
      rawChannels: <double>[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 1.2],
    );
    final result = validator.validate(pkg, _thresholds());

    expect(result, isA<ValidationFailure>());
    expect((result as ValidationFailure).reason,
        'Corrupt packet: channel value out of range');
  });

  test('Rule 4: fails when deviceId is empty', () {
    final pkg = _basePackage(deviceId: '');
    final result = validator.validate(pkg, _thresholds());

    expect(result, isA<ValidationFailure>());
    expect((result as ValidationFailure).reason, 'Missing device ID');
  });

  test('Rule 5: fails when schemaVersion mismatches thresholds', () {
    final pkg = _basePackage(schemaVersion: 2);
    final result = validator.validate(pkg, _thresholds(schemaVersion: 1));

    expect(result, isA<ValidationFailure>());
    expect((result as ValidationFailure).reason, 'Schema version mismatch');
  });
}

