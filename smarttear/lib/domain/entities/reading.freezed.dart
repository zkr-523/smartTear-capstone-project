// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reading _$ReadingFromJson(Map<String, dynamic> json) {
  return _Reading.fromJson(json);
}

/// @nodoc
mixin _$Reading {
  int? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  DateTime get takenAt => throw _privateConstructorUsedError;
  String get sampleStatus => throw _privateConstructorUsedError;
  int? get contactDurationMs => throw _privateConstructorUsedError;
  QCStatus get qcStatus => throw _privateConstructorUsedError;
  String? get invalidReason => throw _privateConstructorUsedError;
  String get modelVersion => throw _privateConstructorUsedError;
  String get rawPackageRef => throw _privateConstructorUsedError;
  List<AnalyteValue> get analytes => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadingCopyWith<Reading> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingCopyWith<$Res> {
  factory $ReadingCopyWith(Reading value, $Res Function(Reading) then) =
      _$ReadingCopyWithImpl<$Res, Reading>;
  @useResult
  $Res call(
      {int? id,
      String userId,
      String deviceId,
      DateTime takenAt,
      String sampleStatus,
      int? contactDurationMs,
      QCStatus qcStatus,
      String? invalidReason,
      String modelVersion,
      String rawPackageRef,
      List<AnalyteValue> analytes,
      String? note});
}

/// @nodoc
class _$ReadingCopyWithImpl<$Res, $Val extends Reading>
    implements $ReadingCopyWith<$Res> {
  _$ReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? deviceId = null,
    Object? takenAt = null,
    Object? sampleStatus = null,
    Object? contactDurationMs = freezed,
    Object? qcStatus = null,
    Object? invalidReason = freezed,
    Object? modelVersion = null,
    Object? rawPackageRef = null,
    Object? analytes = null,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sampleStatus: null == sampleStatus
          ? _value.sampleStatus
          : sampleStatus // ignore: cast_nullable_to_non_nullable
              as String,
      contactDurationMs: freezed == contactDurationMs
          ? _value.contactDurationMs
          : contactDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      qcStatus: null == qcStatus
          ? _value.qcStatus
          : qcStatus // ignore: cast_nullable_to_non_nullable
              as QCStatus,
      invalidReason: freezed == invalidReason
          ? _value.invalidReason
          : invalidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      modelVersion: null == modelVersion
          ? _value.modelVersion
          : modelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      rawPackageRef: null == rawPackageRef
          ? _value.rawPackageRef
          : rawPackageRef // ignore: cast_nullable_to_non_nullable
              as String,
      analytes: null == analytes
          ? _value.analytes
          : analytes // ignore: cast_nullable_to_non_nullable
              as List<AnalyteValue>,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadingImplCopyWith<$Res> implements $ReadingCopyWith<$Res> {
  factory _$$ReadingImplCopyWith(
          _$ReadingImpl value, $Res Function(_$ReadingImpl) then) =
      __$$ReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String userId,
      String deviceId,
      DateTime takenAt,
      String sampleStatus,
      int? contactDurationMs,
      QCStatus qcStatus,
      String? invalidReason,
      String modelVersion,
      String rawPackageRef,
      List<AnalyteValue> analytes,
      String? note});
}

/// @nodoc
class __$$ReadingImplCopyWithImpl<$Res>
    extends _$ReadingCopyWithImpl<$Res, _$ReadingImpl>
    implements _$$ReadingImplCopyWith<$Res> {
  __$$ReadingImplCopyWithImpl(
      _$ReadingImpl _value, $Res Function(_$ReadingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? deviceId = null,
    Object? takenAt = null,
    Object? sampleStatus = null,
    Object? contactDurationMs = freezed,
    Object? qcStatus = null,
    Object? invalidReason = freezed,
    Object? modelVersion = null,
    Object? rawPackageRef = null,
    Object? analytes = null,
    Object? note = freezed,
  }) {
    return _then(_$ReadingImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sampleStatus: null == sampleStatus
          ? _value.sampleStatus
          : sampleStatus // ignore: cast_nullable_to_non_nullable
              as String,
      contactDurationMs: freezed == contactDurationMs
          ? _value.contactDurationMs
          : contactDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      qcStatus: null == qcStatus
          ? _value.qcStatus
          : qcStatus // ignore: cast_nullable_to_non_nullable
              as QCStatus,
      invalidReason: freezed == invalidReason
          ? _value.invalidReason
          : invalidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      modelVersion: null == modelVersion
          ? _value.modelVersion
          : modelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      rawPackageRef: null == rawPackageRef
          ? _value.rawPackageRef
          : rawPackageRef // ignore: cast_nullable_to_non_nullable
              as String,
      analytes: null == analytes
          ? _value._analytes
          : analytes // ignore: cast_nullable_to_non_nullable
              as List<AnalyteValue>,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingImpl extends _Reading {
  const _$ReadingImpl(
      {this.id,
      required this.userId,
      required this.deviceId,
      required this.takenAt,
      required this.sampleStatus,
      this.contactDurationMs,
      required this.qcStatus,
      this.invalidReason,
      required this.modelVersion,
      required this.rawPackageRef,
      required final List<AnalyteValue> analytes,
      this.note})
      : _analytes = analytes,
        super._();

  factory _$ReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingImplFromJson(json);

  @override
  final int? id;
  @override
  final String userId;
  @override
  final String deviceId;
  @override
  final DateTime takenAt;
  @override
  final String sampleStatus;
  @override
  final int? contactDurationMs;
  @override
  final QCStatus qcStatus;
  @override
  final String? invalidReason;
  @override
  final String modelVersion;
  @override
  final String rawPackageRef;
  final List<AnalyteValue> _analytes;
  @override
  List<AnalyteValue> get analytes {
    if (_analytes is EqualUnmodifiableListView) return _analytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_analytes);
  }

  @override
  final String? note;

  @override
  String toString() {
    return 'Reading(id: $id, userId: $userId, deviceId: $deviceId, takenAt: $takenAt, sampleStatus: $sampleStatus, contactDurationMs: $contactDurationMs, qcStatus: $qcStatus, invalidReason: $invalidReason, modelVersion: $modelVersion, rawPackageRef: $rawPackageRef, analytes: $analytes, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.sampleStatus, sampleStatus) ||
                other.sampleStatus == sampleStatus) &&
            (identical(other.contactDurationMs, contactDurationMs) ||
                other.contactDurationMs == contactDurationMs) &&
            (identical(other.qcStatus, qcStatus) ||
                other.qcStatus == qcStatus) &&
            (identical(other.invalidReason, invalidReason) ||
                other.invalidReason == invalidReason) &&
            (identical(other.modelVersion, modelVersion) ||
                other.modelVersion == modelVersion) &&
            (identical(other.rawPackageRef, rawPackageRef) ||
                other.rawPackageRef == rawPackageRef) &&
            const DeepCollectionEquality().equals(other._analytes, _analytes) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      deviceId,
      takenAt,
      sampleStatus,
      contactDurationMs,
      qcStatus,
      invalidReason,
      modelVersion,
      rawPackageRef,
      const DeepCollectionEquality().hash(_analytes),
      note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingImplCopyWith<_$ReadingImpl> get copyWith =>
      __$$ReadingImplCopyWithImpl<_$ReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingImplToJson(
      this,
    );
  }
}

abstract class _Reading extends Reading {
  const factory _Reading(
      {final int? id,
      required final String userId,
      required final String deviceId,
      required final DateTime takenAt,
      required final String sampleStatus,
      final int? contactDurationMs,
      required final QCStatus qcStatus,
      final String? invalidReason,
      required final String modelVersion,
      required final String rawPackageRef,
      required final List<AnalyteValue> analytes,
      final String? note}) = _$ReadingImpl;
  const _Reading._() : super._();

  factory _Reading.fromJson(Map<String, dynamic> json) = _$ReadingImpl.fromJson;

  @override
  int? get id;
  @override
  String get userId;
  @override
  String get deviceId;
  @override
  DateTime get takenAt;
  @override
  String get sampleStatus;
  @override
  int? get contactDurationMs;
  @override
  QCStatus get qcStatus;
  @override
  String? get invalidReason;
  @override
  String get modelVersion;
  @override
  String get rawPackageRef;
  @override
  List<AnalyteValue> get analytes;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$ReadingImplCopyWith<_$ReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
