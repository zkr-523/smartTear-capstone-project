// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DataPackage _$DataPackageFromJson(Map<String, dynamic> json) {
  return _DataPackage.fromJson(json);
}

/// @nodoc
mixin _$DataPackage {
  String get id => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get schemaVersion => throw _privateConstructorUsedError;
  String get sampleStatus =>
      throw _privateConstructorUsedError; // "complete" | "partial" | "failed"
  int? get contactDurationMs => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
  List<double> get rawChannels => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DataPackageCopyWith<DataPackage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataPackageCopyWith<$Res> {
  factory $DataPackageCopyWith(
          DataPackage value, $Res Function(DataPackage) then) =
      _$DataPackageCopyWithImpl<$Res, DataPackage>;
  @useResult
  $Res call(
      {String id,
      String deviceId,
      DateTime timestamp,
      int schemaVersion,
      String sampleStatus,
      int? contactDurationMs,
      @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
      List<double> rawChannels});
}

/// @nodoc
class _$DataPackageCopyWithImpl<$Res, $Val extends DataPackage>
    implements $DataPackageCopyWith<$Res> {
  _$DataPackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? schemaVersion = null,
    Object? sampleStatus = null,
    Object? contactDurationMs = freezed,
    Object? rawChannels = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      schemaVersion: null == schemaVersion
          ? _value.schemaVersion
          : schemaVersion // ignore: cast_nullable_to_non_nullable
              as int,
      sampleStatus: null == sampleStatus
          ? _value.sampleStatus
          : sampleStatus // ignore: cast_nullable_to_non_nullable
              as String,
      contactDurationMs: freezed == contactDurationMs
          ? _value.contactDurationMs
          : contactDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      rawChannels: null == rawChannels
          ? _value.rawChannels
          : rawChannels // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataPackageImplCopyWith<$Res>
    implements $DataPackageCopyWith<$Res> {
  factory _$$DataPackageImplCopyWith(
          _$DataPackageImpl value, $Res Function(_$DataPackageImpl) then) =
      __$$DataPackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceId,
      DateTime timestamp,
      int schemaVersion,
      String sampleStatus,
      int? contactDurationMs,
      @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
      List<double> rawChannels});
}

/// @nodoc
class __$$DataPackageImplCopyWithImpl<$Res>
    extends _$DataPackageCopyWithImpl<$Res, _$DataPackageImpl>
    implements _$$DataPackageImplCopyWith<$Res> {
  __$$DataPackageImplCopyWithImpl(
      _$DataPackageImpl _value, $Res Function(_$DataPackageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? schemaVersion = null,
    Object? sampleStatus = null,
    Object? contactDurationMs = freezed,
    Object? rawChannels = null,
  }) {
    return _then(_$DataPackageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      schemaVersion: null == schemaVersion
          ? _value.schemaVersion
          : schemaVersion // ignore: cast_nullable_to_non_nullable
              as int,
      sampleStatus: null == sampleStatus
          ? _value.sampleStatus
          : sampleStatus // ignore: cast_nullable_to_non_nullable
              as String,
      contactDurationMs: freezed == contactDurationMs
          ? _value.contactDurationMs
          : contactDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      rawChannels: null == rawChannels
          ? _value._rawChannels
          : rawChannels // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataPackageImpl extends _DataPackage {
  const _$DataPackageImpl(
      {required this.id,
      required this.deviceId,
      required this.timestamp,
      required this.schemaVersion,
      required this.sampleStatus,
      this.contactDurationMs,
      @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
      required final List<double> rawChannels})
      : _rawChannels = rawChannels,
        super._();

  factory _$DataPackageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataPackageImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceId;
  @override
  final DateTime timestamp;
  @override
  final int schemaVersion;
  @override
  final String sampleStatus;
// "complete" | "partial" | "failed"
  @override
  final int? contactDurationMs;
  final List<double> _rawChannels;
  @override
  @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
  List<double> get rawChannels {
    if (_rawChannels is EqualUnmodifiableListView) return _rawChannels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rawChannels);
  }

  @override
  String toString() {
    return 'DataPackage(id: $id, deviceId: $deviceId, timestamp: $timestamp, schemaVersion: $schemaVersion, sampleStatus: $sampleStatus, contactDurationMs: $contactDurationMs, rawChannels: $rawChannels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataPackageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.schemaVersion, schemaVersion) ||
                other.schemaVersion == schemaVersion) &&
            (identical(other.sampleStatus, sampleStatus) ||
                other.sampleStatus == sampleStatus) &&
            (identical(other.contactDurationMs, contactDurationMs) ||
                other.contactDurationMs == contactDurationMs) &&
            const DeepCollectionEquality()
                .equals(other._rawChannels, _rawChannels));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deviceId,
      timestamp,
      schemaVersion,
      sampleStatus,
      contactDurationMs,
      const DeepCollectionEquality().hash(_rawChannels));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataPackageImplCopyWith<_$DataPackageImpl> get copyWith =>
      __$$DataPackageImplCopyWithImpl<_$DataPackageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataPackageImplToJson(
      this,
    );
  }
}

abstract class _DataPackage extends DataPackage {
  const factory _DataPackage(
      {required final String id,
      required final String deviceId,
      required final DateTime timestamp,
      required final int schemaVersion,
      required final String sampleStatus,
      final int? contactDurationMs,
      @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
      required final List<double> rawChannels}) = _$DataPackageImpl;
  const _DataPackage._() : super._();

  factory _DataPackage.fromJson(Map<String, dynamic> json) =
      _$DataPackageImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceId;
  @override
  DateTime get timestamp;
  @override
  int get schemaVersion;
  @override
  String get sampleStatus;
  @override // "complete" | "partial" | "failed"
  int? get contactDurationMs;
  @override
  @JsonKey(fromJson: _doubleListFromJson, toJson: _doubleListToJson)
  List<double> get rawChannels;
  @override
  @JsonKey(ignore: true)
  _$$DataPackageImplCopyWith<_$DataPackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
