// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyte_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyteValueImpl _$$AnalyteValueImplFromJson(Map<String, dynamic> json) =>
    _$AnalyteValueImpl(
      analyteCode: json['analyteCode'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedBG: (json['estimatedBG'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$AnalyteValueImplToJson(_$AnalyteValueImpl instance) =>
    <String, dynamic>{
      'analyteCode': instance.analyteCode,
      'value': instance.value,
      'unit': instance.unit,
      'estimatedBG': instance.estimatedBG,
    };
