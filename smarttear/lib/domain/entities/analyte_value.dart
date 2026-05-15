import 'package:freezed_annotation/freezed_annotation.dart';

part 'analyte_value.freezed.dart';
part 'analyte_value.g.dart';

@freezed
class AnalyteValue with _$AnalyteValue {
  const factory AnalyteValue({
    required String analyteCode, // "TG" | "Na" | "K" | "Cl" | "Chol"
    required double value,
    required String unit,
    double? estimatedBG, // optional TG to BG mapped value
  }) = _AnalyteValue;

  factory AnalyteValue.fromJson(Map<String, dynamic> json) =>
      _$AnalyteValueFromJson(json);
}

