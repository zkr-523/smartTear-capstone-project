import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'analyte_value.dart';
import 'qc_status.dart';

part 'reading.freezed.dart';
part 'reading.g.dart';

@freezed
class Reading with _$Reading {
  const Reading._();

  const factory Reading({
    int? id,
    required String userId,
    required String deviceId,
    required DateTime takenAt,
    required String sampleStatus,
    int? contactDurationMs,
    required QCStatus qcStatus,
    String? invalidReason,
    required String modelVersion,
    required String rawPackageRef,
    required List<AnalyteValue> analytes,
    String? note,
  }) = _Reading;

  factory Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);

  bool get isValid => qcStatus == QCStatus.valid;

  AnalyteValue? get glucose =>
      analytes.where((a) => a.analyteCode == 'TG').firstOrNull;
}

