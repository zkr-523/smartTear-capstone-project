import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/infrastructure/ml/preprocessor.dart';
import 'package:smarttear/infrastructure/ml/scaler_params.dart';

DataPackage _pkg({
  List<double>? rawChannels,
  int? contactDurationMs = 1500,
}) {
  return DataPackage(
    id: 'pkg-1',
    deviceId: 'dev-1',
    timestamp: DateTime(2026, 1, 1),
    schemaVersion: 1,
    sampleStatus: 'complete',
    contactDurationMs: contactDurationMs,
    rawChannels: rawChannels ?? List<double>.filled(8, 0.5),
  );
}

ScalerParams _scaler({
  List<double>? featureMin,
  List<double>? featureMax,
  List<double>? clipMin,
  List<double>? clipMax,
  int contactMinMs = 500,
  int contactMaxMs = 2500,
}) {
  return ScalerParams(
    featureMin: featureMin ?? List<double>.filled(8, 0.0, growable: false),
    featureMax: featureMax ?? List<double>.filled(8, 1.0, growable: false),
    clipMin: clipMin ?? List<double>.filled(8, 0.0, growable: false),
    clipMax: clipMax ?? List<double>.filled(8, 1.0, growable: false),
    contactDurationMinMs: contactMinMs,
    contactDurationMaxMs: contactMaxMs,
  );
}

void main() {
  const pre = Preprocessor();

  test('PRE-001: output length is 9 (8 channels + 1 contact)', () {
    final out = pre.preprocess(_pkg(), _scaler());
    expect(out.features.length, 9);
  });

  test('PRE-002: midpoint values map to 0.5 with a [0,1] scaler', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 0.5)),
      _scaler(),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], closeTo(0.5, 1e-9));
    }
  });

  test('PRE-003: value at featureMin maps to 0.0', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 0.0)),
      _scaler(),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], 0.0);
    }
  });

  test('PRE-004: value at featureMax maps to 1.0', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 1.0)),
      _scaler(),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], 1.0);
    }
  });

  test('PRE-005: value above clipMax is clipped then normalizes to 1.0', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 5.0)),
      _scaler(),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], 1.0);
    }
  });

  test('PRE-006: value below clipMin is clipped then normalizes to 0.0', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, -5.0)),
      _scaler(),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], 0.0);
    }
  });

  test('PRE-007: normalized output is clamped into [0, 1]', () {
    // Wide clip range allows raw=2 through; featureMin=0,featureMax=1 → raw norm=2
    // The Preprocessor _clamp(raw, 0, 1) ensures the final value stays at 1.0.
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 2.0)),
      _scaler(
        clipMin: List<double>.filled(8, -10.0, growable: false),
        clipMax: List<double>.filled(8, 10.0, growable: false),
      ),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i] >= 0.0 && out.features[i] <= 1.0, isTrue);
      expect(out.features[i], 1.0);
    }
  });

  test('PRE-008: degenerate featureMin == featureMax returns 0 (no divide by zero)', () {
    final out = pre.preprocess(
      _pkg(rawChannels: List<double>.filled(8, 0.42)),
      _scaler(
        featureMin: List<double>.filled(8, 0.5, growable: false),
        featureMax: List<double>.filled(8, 0.5, growable: false),
      ),
    );
    for (var i = 0; i < 8; i++) {
      expect(out.features[i], 0.0);
    }
  });

  test('PRE-009: contact 500 ms maps to 0.0 with default 500-2500 span', () {
    final out = pre.preprocess(_pkg(contactDurationMs: 500), _scaler());
    expect(out.features[8], 0.0);
    expect(out.contactDurationAvailable, isTrue);
  });

  test('PRE-010: contact 2500 ms maps to 1.0', () {
    final out = pre.preprocess(_pkg(contactDurationMs: 2500), _scaler());
    expect(out.features[8], 1.0);
  });

  test('PRE-011: contact 1500 ms maps to 0.5', () {
    final out = pre.preprocess(_pkg(contactDurationMs: 1500), _scaler());
    expect(out.features[8], closeTo(0.5, 1e-9));
  });

  test('PRE-012: contact below minMs is clamped to 0.0', () {
    final out = pre.preprocess(_pkg(contactDurationMs: 100), _scaler());
    expect(out.features[8], 0.0);
  });

  test('PRE-013: contact above maxMs is clamped to 1.0', () {
    final out = pre.preprocess(_pkg(contactDurationMs: 10000), _scaler());
    expect(out.features[8], 1.0);
  });

  test('PRE-014: missing contact duration sets feature 0 and contactDurationAvailable = false', () {
    final out = pre.preprocess(_pkg(contactDurationMs: null), _scaler());
    expect(out.features[8], 0.0);
    expect(out.contactDurationAvailable, isFalse);
  });
}
