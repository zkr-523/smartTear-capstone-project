import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/infrastructure/ml/data_ingestor.dart';
import 'package:smarttear/infrastructure/ml/package_validator.dart';
import 'package:smarttear/infrastructure/ml/preprocessor.dart';
import 'package:smarttear/infrastructure/ml/qc_classifier.dart';
import 'package:smarttear/infrastructure/ml/scaler_params.dart';

import '_fakes.dart';

double _pct(List<double> sorted, double p) {
  if (sorted.isEmpty) return double.nan;
  final idx = ((sorted.length - 1) * p).round();
  return sorted[idx];
}

double _mean(List<double> xs) {
  if (xs.isEmpty) return double.nan;
  var s = 0.0;
  for (final v in xs) {
    s += v;
  }
  return s / xs.length;
}

String _fmt(double v) => v.toStringAsFixed(4);

void main() {
  test('ingest pipeline benchmark', () async {
    const totalIters = 1000;
    const warmup = 100;

    final validator = const PackageValidator();
    final preprocessor = const Preprocessor();
    final qc = const QCClassifier();
    final scaler = ScalerParams.defaultParams();
    final thr = defaultThresholds();
    final model = FakeAnalyteModel();
    final tgBg = FakeTgBgEstimator(null);
    final repo = FakeRepository();

    final ingestor = DataIngestor(
      validator: validator,
      preprocessor: preprocessor,
      modelPort: model,
      qcClassifier: qc,
      thresholds: thr,
      scaler: scaler,
      repository: repo,
      tgBgModel: tgBg,
    );

    final pkt = validPacket();

    // -- Loop A: end-to-end ingest --
    final e2e = <double>[];
    for (var i = 0; i < totalIters; i++) {
      final sw = Stopwatch()..start();
      final res = await ingestor.ingest(pkt, 'user-1');
      sw.stop();
      // Sanity: ensure success path (don't fail bench if not, but assert once)
      if (i == 0) {
        expect(res, isA<IngestSuccess>());
      }
      if (i >= warmup) {
        e2e.add(sw.elapsedMicroseconds / 1000.0);
      }
    }
    e2e.sort();

    // -- Loop B: per-stage --
    final validateMs = <double>[];
    final preprocessMs = <double>[];
    final modelMs = <double>[];
    final qcMs = <double>[];

    for (var i = 0; i < totalIters; i++) {
      final sw1 = Stopwatch()..start();
      final vr = validator.validate(pkt, thr);
      sw1.stop();

      final sw2 = Stopwatch()..start();
      final feats = preprocessor.preprocess(pkt, scaler);
      sw2.stop();

      final sw3 = Stopwatch()..start();
      final analytes = await model.estimate(feats.features);
      sw3.stop();

      final sw4 = Stopwatch()..start();
      qc.classify(pkt, analytes, thr);
      sw4.stop();

      // Touch vr to avoid dead-code elimination concerns.
      if (i == 0) {
        expect(vr, isA<ValidationResult>());
      }

      if (i >= warmup) {
        validateMs.add(sw1.elapsedMicroseconds / 1000.0);
        preprocessMs.add(sw2.elapsedMicroseconds / 1000.0);
        modelMs.add(sw3.elapsedMicroseconds / 1000.0);
        qcMs.add(sw4.elapsedMicroseconds / 1000.0);
      }
    }
    validateMs.sort();
    preprocessMs.sort();
    modelMs.sort();
    qcMs.sort();

    print('=== Ingest pipeline benchmark ===');
    print('iterations_total: $totalIters');
    print('warmup: $warmup');
    print('counted: ${e2e.length}');
    print('');
    print('-- End-to-end latency (ms) --');
    print('min: ${_fmt(e2e.first)}');
    print('p50: ${_fmt(_pct(e2e, 0.50))}');
    print('p95: ${_fmt(_pct(e2e, 0.95))}');
    print('p99: ${_fmt(_pct(e2e, 0.99))}');
    print('max: ${_fmt(e2e.last)}');
    print('mean: ${_fmt(_mean(e2e))}');
    print('');
    print('-- Per-stage latency (ms, p50 / p95) --');
    print('validate: ${_fmt(_pct(validateMs, 0.50))} / ${_fmt(_pct(validateMs, 0.95))}');
    print('preprocess: ${_fmt(_pct(preprocessMs, 0.50))} / ${_fmt(_pct(preprocessMs, 0.95))}');
    print('model.estimate (fake): ${_fmt(_pct(modelMs, 0.50))} / ${_fmt(_pct(modelMs, 0.95))}');
    print('qc.classify: ${_fmt(_pct(qcMs, 0.50))} / ${_fmt(_pct(qcMs, 0.95))}');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
