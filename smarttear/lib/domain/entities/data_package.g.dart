// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DataPackageImpl _$$DataPackageImplFromJson(Map<String, dynamic> json) =>
    _$DataPackageImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      sampleStatus: json['sampleStatus'] as String,
      contactDurationMs: (json['contactDurationMs'] as num?)?.toInt(),
      rawChannels: _doubleListFromJson(json['rawChannels']),
    );

Map<String, dynamic> _$$DataPackageImplToJson(_$DataPackageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'timestamp': instance.timestamp.toIso8601String(),
      'schemaVersion': instance.schemaVersion,
      'sampleStatus': instance.sampleStatus,
      'contactDurationMs': instance.contactDurationMs,
      'rawChannels': _doubleListToJson(instance.rawChannels),
    };
