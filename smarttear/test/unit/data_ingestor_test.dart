import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/analyte_value.dart';
import 'package:smarttear/domain/entities/chat_message_view.dart';
import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/domain/entities/qc_status.dart';
import 'package:smarttear/domain/entities/reading.dart';
import 'package:smarttear/domain/repositories/reading_repository_port.dart';
import 'package:smarttear/domain/services/analyte_model_port.dart';
import 'package:smarttear/domain/services/tg_bg_estimator_port.dart';
import 'package:smarttear/infrastructure/ml/data_ingestor.dart';
import 'package:smarttear/infrastructure/ml/package_validator.dart';
import 'package:smarttear/infrastructure/ml/preprocessor.dart';
import 'package:smarttear/infrastructure/ml/qc_classifier.dart';
import 'package:smarttear/infrastructure/ml/qc_thresholds.dart';
import 'package:smarttear/infrastructure/ml/scaler_params.dart';

class _FakeRepository implements ReadingRepositoryPort {
  final List<DataPackage> rawSaves = [];
  final List<Reading> readingSaves = [];
  final List<String> callOrder = [];
  bool throwOnRaw = false;
  bool throwOnReading = false;

  @override
  Future<String> saveRawPackage(DataPackage package) async {
    callOrder.add('raw');
    if (throwOnRaw) throw Exception('disk full');
    rawSaves.add(package);
    return 'ref-${rawSaves.length}';
  }

  @override
  Future<void> saveReading(Reading reading) async {
    callOrder.add('reading');
    if (throwOnReading) throw Exception('db locked');
    readingSaves.add(reading);
  }

  @override
  Future<Reading?> getReadingByRef(String readingId) async => null;
  @override
  Future<List<Reading>> latestReadings({int limit = 10}) async => const [];
  @override
  Future<List<Reading>> listReadingsForUser(String userId,
          {int limit = 500}) async =>
      const [];
  @override
  Future<void> updateReadingNote(
      String readingRef, String userId, String? note) async {}
  @override
  Future<void> deleteReading(String readingRef, String userId) async {}
  @override
  Future<void> mergeReadings(List<Reading> readings, String userId) async {}
  @override
  Future<List<ChatMessageView>> loadChatMessages({
    required String userId,
    required int? readingId,
    int limit = 200,
  }) async =>
      const [];
  @override
  Future<void> saveChatMessage({
    required String userId,
    required int? readingId,
    required String role,
    required String text,
    DateTime? createdAt,
  }) async {}
}

class _FakeAnalyteModel implements AnalyteModelPort {
  _FakeAnalyteModel({this.shouldThrow = false, this.tgValue = 0.5});
  final bool shouldThrow;
  final double tgValue;

  @override
  String get modelVersion => 'fake-v1';

  @override
  Future<List<AnalyteValue>> estimate(List<double> features) async {
    if (shouldThrow) throw Exception('model boom');
    return [
      AnalyteValue(analyteCode: 'TG', value: tgValue, unit: 'mmol/L'),
      const AnalyteValue(analyteCode: 'Na', value: 140.0, unit: 'mEq/L'),
    ];
  }
}

class _FakeTgBgEstimator implements TgBgEstimatorPort {
  _FakeTgBgEstimator(this.response);
  final double? response;
  @override
  double? estimateBG(double tgMmol) => response;
}

DataPackage _pkg({
  String sampleStatus = 'complete',
  List<double>? rawChannels,
}) {
  return DataPackage(
    id: 'pkg-1',
    deviceId: 'dev-1',
    timestamp: DateTime(2026, 1, 1),
    schemaVersion: 1,
    sampleStatus: sampleStatus,
    contactDurationMs: 1500,
    rawChannels: rawChannels ??
        const [0.1, 0.3, 0.5, 0.7, 0.9, 0.5, 0.5, 0.5],
  );
}

QCThresholds _thr() => QCThresholds.fromJson(<String, Object>{
      'min_contact_duration_ms': 500,
      'min_channel_variance': 0.001,
      'glucose_min': 0.1,
      'glucose_max': 0.95,
      'schema_version': 1,
    });

DataIngestor _ingestor({
  required _FakeRepository repo,
  _FakeAnalyteModel? model,
  _FakeTgBgEstimator? tgBg,
}) {
  return DataIngestor(
    validator: const PackageValidator(),
    preprocessor: const Preprocessor(),
    modelPort: model ?? _FakeAnalyteModel(),
    qcClassifier: const QCClassifier(),
    thresholds: _thr(),
    scaler: ScalerParams.defaultParams(),
    repository: repo,
    tgBgModel: tgBg ?? _FakeTgBgEstimator(null),
  );
}

void main() {
  test('ING-001: happy path returns IngestSuccess with persisted reading', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(repo: repo);
    final res = await ing.ingest(_pkg(), 'user-1');

    expect(res, isA<IngestSuccess>());
    expect(repo.rawSaves.length, 1);
    expect(repo.readingSaves.length, 1);
    expect(repo.readingSaves.single.modelVersion, 'fake-v1');
  });

  test('ING-002: rawChannels length != 8 returns IngestFailure (non-retryable)', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(repo: repo);
    final res = await ing.ingest(
      _pkg(rawChannels: const [0.5, 0.5]),
      'user-1',
    );

    expect(res, isA<IngestFailure>());
    expect((res as IngestFailure).isRetryable, isFalse);
    expect(repo.rawSaves, isEmpty);
    expect(repo.readingSaves, isEmpty);
  });

  test('ING-003: saveRawPackage throws → IngestFailure(retryable), no reading save', () async {
    final repo = _FakeRepository()..throwOnRaw = true;
    final ing = _ingestor(repo: repo);
    final res = await ing.ingest(_pkg(), 'user-1');

    expect(res, isA<IngestFailure>());
    expect((res as IngestFailure).isRetryable, isTrue);
    expect(repo.readingSaves, isEmpty);
  });

  test('ING-004: model estimate throws → IngestFailure(retryable), raw save happened first', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(
      repo: repo,
      model: _FakeAnalyteModel(shouldThrow: true),
    );
    final res = await ing.ingest(_pkg(), 'user-1');

    expect(res, isA<IngestFailure>());
    expect((res as IngestFailure).isRetryable, isTrue);
    expect(repo.rawSaves.length, 1);
    expect(repo.readingSaves, isEmpty);
    expect(repo.callOrder.first, 'raw');
  });

  test('ING-005: saveReading throws → IngestFailure(retryable)', () async {
    final repo = _FakeRepository()..throwOnReading = true;
    final ing = _ingestor(repo: repo);
    final res = await ing.ingest(_pkg(), 'user-1');

    expect(res, isA<IngestFailure>());
    expect((res as IngestFailure).isRetryable, isTrue);
  });

  test('ING-006: QC invalid still produces IngestSuccess and the invalid reading is persisted', () async {
    final repo = _FakeRepository();
    // Out-of-range glucose makes QC invalid.
    final ing = _ingestor(
      repo: repo,
      model: _FakeAnalyteModel(tgValue: 99.0),
    );
    final res = await ing.ingest(_pkg(), 'user-1');

    expect(res, isA<IngestSuccess>());
    expect(repo.readingSaves.single.qcStatus, QCStatus.invalid);
  });

  test('ING-007: estBgEnabled=true and model returns 7.5 → TG analyte has estimatedBG=7.5', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(
      repo: repo,
      tgBg: _FakeTgBgEstimator(7.5),
    );
    final res = await ing.ingest(_pkg(), 'user-1', estBgEnabled: true);

    expect(res, isA<IngestSuccess>());
    final tg = (res as IngestSuccess)
        .reading
        .analytes
        .firstWhere((a) => a.analyteCode == 'TG');
    expect(tg.estimatedBG, 7.5);
  });

  test('ING-008: estBgEnabled=false → TG analyte estimatedBG is null', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(
      repo: repo,
      tgBg: _FakeTgBgEstimator(7.5),
    );
    final res = await ing.ingest(_pkg(), 'user-1', estBgEnabled: false);

    final tg = (res as IngestSuccess)
        .reading
        .analytes
        .firstWhere((a) => a.analyteCode == 'TG');
    expect(tg.estimatedBG, isNull);
  });

  test('ING-009: estBgEnabled=true and model returns null → analytes unchanged', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(
      repo: repo,
      tgBg: _FakeTgBgEstimator(null),
    );
    final res = await ing.ingest(_pkg(), 'user-1', estBgEnabled: true);

    final tg = (res as IngestSuccess)
        .reading
        .analytes
        .firstWhere((a) => a.analyteCode == 'TG');
    expect(tg.estimatedBG, isNull);
  });

  test('ING-010: validation failure (sampleStatus="failed") happens before raw write-ahead', () async {
    final repo = _FakeRepository();
    final ing = _ingestor(repo: repo);
    final res = await ing.ingest(_pkg(sampleStatus: 'failed'), 'user-1');

    expect(res, isA<IngestFailure>());
    expect(repo.rawSaves, isEmpty);
    expect(repo.readingSaves, isEmpty);
  });
}
