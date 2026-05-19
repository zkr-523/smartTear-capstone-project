import 'package:smarttear/domain/entities/analyte_value.dart';
import 'package:smarttear/domain/entities/chat_message_view.dart';
import 'package:smarttear/domain/entities/data_package.dart';
import 'package:smarttear/domain/entities/reading.dart';
import 'package:smarttear/domain/repositories/reading_repository_port.dart';
import 'package:smarttear/domain/services/analyte_model_port.dart';
import 'package:smarttear/domain/services/tg_bg_estimator_port.dart';
import 'package:smarttear/infrastructure/ml/qc_thresholds.dart';

class FakeRepository implements ReadingRepositoryPort {
  final List<DataPackage> rawSaves = [];
  final List<Reading> readingSaves = [];
  int _refCounter = 0;

  @override
  Future<String> saveRawPackage(DataPackage package) async {
    _refCounter++;
    rawSaves.add(package);
    return 'ref-$_refCounter';
  }

  @override
  Future<void> saveReading(Reading reading) async {
    readingSaves.add(reading);
  }

  @override
  Future<Reading?> getReadingByRef(String readingId) async => null;
  @override
  Future<List<Reading>> latestReadings({int limit = 10}) async => const [];
  @override
  Future<List<Reading>> listReadingsForUser(String userId, {int limit = 500}) async => const [];
  @override
  Future<void> updateReadingNote(String readingRef, String userId, String? note) async {}
  @override
  Future<void> deleteReading(String readingRef, String userId) async {}
  @override
  Future<void> mergeReadings(List<Reading> readings, String userId) async {}
  @override
  Future<List<ChatMessageView>> loadChatMessages({
    required String userId,
    required int? readingId,
    int limit = 200,
  }) async => const [];
  @override
  Future<void> saveChatMessage({
    required String userId,
    required int? readingId,
    required String role,
    required String text,
    DateTime? createdAt,
  }) async {}
}

class FakeAnalyteModel implements AnalyteModelPort {
  FakeAnalyteModel({this.tgValue = 0.5});
  final double tgValue;

  @override
  String get modelVersion => 'fake-v1';

  @override
  Future<List<AnalyteValue>> estimate(List<double> features) async {
    return [
      AnalyteValue(analyteCode: 'TG', value: tgValue, unit: 'mmol/L'),
      const AnalyteValue(analyteCode: 'Na', value: 140.0, unit: 'mEq/L'),
    ];
  }
}

class FakeTgBgEstimator implements TgBgEstimatorPort {
  FakeTgBgEstimator(this.response);
  final double? response;
  @override
  double? estimateBG(double tgMmol) => response;
}

DataPackage validPacket() => DataPackage(
      id: 'pkg-1',
      deviceId: 'dev-1',
      timestamp: DateTime(2026, 1, 1),
      schemaVersion: 1,
      sampleStatus: 'complete',
      contactDurationMs: 1500,
      rawChannels: const [0.1, 0.3, 0.5, 0.7, 0.9, 0.5, 0.5, 0.5],
    );

QCThresholds defaultThresholds() => QCThresholds.fromJson(<String, Object>{
      'min_contact_duration_ms': 500,
      'min_channel_variance': 0.001,
      'glucose_min': 0.1,
      'glucose_max': 0.95,
      'schema_version': 1,
    });
