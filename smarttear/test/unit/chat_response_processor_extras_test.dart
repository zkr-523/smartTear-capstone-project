import 'package:flutter_test/flutter_test.dart';
import 'package:smarttear/domain/entities/analyte_value.dart';
import 'package:smarttear/domain/entities/qc_status.dart';
import 'package:smarttear/domain/entities/reading.dart';
import 'package:smarttear/infrastructure/assistant/chat_response_processor.dart';

Reading _reading({
  List<AnalyteValue>? analytes,
  QCStatus qcStatus = QCStatus.valid,
  String? invalidReason,
}) {
  return Reading(
    id: 1,
    userId: 'u',
    deviceId: 'dev-1',
    takenAt: DateTime(2026, 1, 1),
    sampleStatus: 'complete',
    contactDurationMs: 1500,
    qcStatus: qcStatus,
    invalidReason: invalidReason,
    modelVersion: 'v1',
    rawPackageRef: 'ref-1',
    analytes: analytes ??
        const [
          AnalyteValue(analyteCode: 'TG', value: 0.9, unit: 'mmol/L'),
          AnalyteValue(analyteCode: 'Na', value: 130.0, unit: 'mEq/L'),
        ],
  );
}

void main() {
  test('CHAT-005: enforceShortResponse with maxSentences=2 keeps exactly two sentences', () {
    const raw = 'One. Two. Three. Four.';
    final out = enforceShortResponse(raw, maxSentences: 2);
    final parts = splitChatSentences(out);
    expect(parts.length, 2);
  });

  test('CHAT-006: empty input returns empty', () {
    expect(enforceShortResponse(''), '');
  });

  test('CHAT-007: bold markdown is stripped, numeric values preserved', () {
    final out = cleanResponse('**TG 0.9 mmol/L** is high.');
    expect(out, isNot(contains('**')));
    expect(out, contains('0.9'));
    expect(out, contains('TG'));
  });

  test('CHAT-008: localReadingFallback("hello", null) returns null', () {
    expect(localReadingFallback('hello', null), isNull);
  });

  test('CHAT-009: TG question returns the numeric TG value', () {
    final out = localReadingFallback('what is my TG?', _reading());
    expect(out, isNotNull);
    expect(out, contains('0.9'));
  });

  test('CHAT-010: "why invalid" returns reply echoing stored invalidReason', () {
    final r = _reading(
      qcStatus: QCStatus.invalid,
      invalidReason: 'Contact time too short',
    );
    final out = localReadingFallback('why was this invalid?', r);
    expect(out, isNotNull);
    expect(out, contains('Contact time too short'));
  });

  test('CHAT-011: summary question lists Valid/Invalid and TG band label', () {
    final out = localReadingFallback('summarize this reading', _reading());
    expect(out, isNotNull);
    expect(out, contains('Valid'));
    expect(out, contains('TG'));
  });
}
