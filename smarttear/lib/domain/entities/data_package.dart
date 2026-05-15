import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_package.freezed.dart';
part 'data_package.g.dart';

@freezed
class DataPackage with _$DataPackage {
  const DataPackage._();

  const factory DataPackage({
    required String id,
    required String deviceId,
    required DateTime timestamp,
    required int schemaVersion,
    required String sampleStatus, // "complete" | "partial" | "failed"
    int? contactDurationMs,
    @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
    required List<double> rawChannels, // exactly 8 values
  }) = _DataPackage;

  factory DataPackage.fromJson(Map<String, dynamic> json) =>
      _$DataPackageFromJson(json);

  List<String> validate() {
    final errors = <String>[];

    if (rawChannels.length != 8) {
      errors.add('rawChannels must have exactly 8 elements');
    }

    const allowedStatuses = {'complete', 'partial', 'failed'};
    if (!allowedStatuses.contains(sampleStatus)) {
      errors.add('sampleStatus must be complete / partial / failed');
    }

    if (schemaVersion != 1) {
      errors.add('schemaVersion must be 1');
    }

    if (deviceId.trim().isEmpty) {
      errors.add('deviceId must not be empty');
    }

    return errors;
  }
}

List<double> _doubleListFromJson(Object? value) {
  final list = value as List<dynamic>? ?? const <dynamic>[];
  return list.map((e) => (e as num).toDouble()).toList(growable: false);
}

Object _doubleListToJson(List<double> value) => value;

