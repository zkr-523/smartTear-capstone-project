// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadingImpl _$$ReadingImplFromJson(Map<String, dynamic> json) =>
    _$ReadingImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      takenAt: DateTime.parse(json['takenAt'] as String),
      sampleStatus: json['sampleStatus'] as String,
      contactDurationMs: (json['contactDurationMs'] as num?)?.toInt(),
      qcStatus: $enumDecode(_$QCStatusEnumMap, json['qcStatus']),
      invalidReason: json['invalidReason'] as String?,
      modelVersion: json['modelVersion'] as String,
      rawPackageRef: json['rawPackageRef'] as String,
      analytes: (json['analytes'] as List<dynamic>)
          .map((e) => AnalyteValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ReadingImplToJson(_$ReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'takenAt': instance.takenAt.toIso8601String(),
      'sampleStatus': instance.sampleStatus,
      'contactDurationMs': instance.contactDurationMs,
      'qcStatus': _$QCStatusEnumMap[instance.qcStatus]!,
      'invalidReason': instance.invalidReason,
      'modelVersion': instance.modelVersion,
      'rawPackageRef': instance.rawPackageRef,
      'analytes': instance.analytes,
      'note': instance.note,
    };

const _$QCStatusEnumMap = {
  QCStatus.valid: 'valid',
  QCStatus.invalid: 'invalid',
};
