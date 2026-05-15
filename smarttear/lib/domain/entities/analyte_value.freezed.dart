// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analyte_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnalyteValue _$AnalyteValueFromJson(Map<String, dynamic> json) {
  return _AnalyteValue.fromJson(json);
}

/// @nodoc
mixin _$AnalyteValue {
  String get analyteCode =>
      throw _privateConstructorUsedError; // "TG" | "Na" | "K" | "Cl" | "Chol"
  double get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  double? get estimatedBG => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnalyteValueCopyWith<AnalyteValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyteValueCopyWith<$Res> {
  factory $AnalyteValueCopyWith(
          AnalyteValue value, $Res Function(AnalyteValue) then) =
      _$AnalyteValueCopyWithImpl<$Res, AnalyteValue>;
  @useResult
  $Res call(
      {String analyteCode, double value, String unit, double? estimatedBG});
}

/// @nodoc
class _$AnalyteValueCopyWithImpl<$Res, $Val extends AnalyteValue>
    implements $AnalyteValueCopyWith<$Res> {
  _$AnalyteValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analyteCode = null,
    Object? value = null,
    Object? unit = null,
    Object? estimatedBG = freezed,
  }) {
    return _then(_value.copyWith(
      analyteCode: null == analyteCode
          ? _value.analyteCode
          : analyteCode // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedBG: freezed == estimatedBG
          ? _value.estimatedBG
          : estimatedBG // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalyteValueImplCopyWith<$Res>
    implements $AnalyteValueCopyWith<$Res> {
  factory _$$AnalyteValueImplCopyWith(
          _$AnalyteValueImpl value, $Res Function(_$AnalyteValueImpl) then) =
      __$$AnalyteValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String analyteCode, double value, String unit, double? estimatedBG});
}

/// @nodoc
class __$$AnalyteValueImplCopyWithImpl<$Res>
    extends _$AnalyteValueCopyWithImpl<$Res, _$AnalyteValueImpl>
    implements _$$AnalyteValueImplCopyWith<$Res> {
  __$$AnalyteValueImplCopyWithImpl(
      _$AnalyteValueImpl _value, $Res Function(_$AnalyteValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analyteCode = null,
    Object? value = null,
    Object? unit = null,
    Object? estimatedBG = freezed,
  }) {
    return _then(_$AnalyteValueImpl(
      analyteCode: null == analyteCode
          ? _value.analyteCode
          : analyteCode // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedBG: freezed == estimatedBG
          ? _value.estimatedBG
          : estimatedBG // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyteValueImpl implements _AnalyteValue {
  const _$AnalyteValueImpl(
      {required this.analyteCode,
      required this.value,
      required this.unit,
      this.estimatedBG});

  factory _$AnalyteValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyteValueImplFromJson(json);

  @override
  final String analyteCode;
// "TG" | "Na" | "K" | "Cl" | "Chol"
  @override
  final double value;
  @override
  final String unit;
  @override
  final double? estimatedBG;

  @override
  String toString() {
    return 'AnalyteValue(analyteCode: $analyteCode, value: $value, unit: $unit, estimatedBG: $estimatedBG)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyteValueImpl &&
            (identical(other.analyteCode, analyteCode) ||
                other.analyteCode == analyteCode) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.estimatedBG, estimatedBG) ||
                other.estimatedBG == estimatedBG));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, analyteCode, value, unit, estimatedBG);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyteValueImplCopyWith<_$AnalyteValueImpl> get copyWith =>
      __$$AnalyteValueImplCopyWithImpl<_$AnalyteValueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyteValueImplToJson(
      this,
    );
  }
}

abstract class _AnalyteValue implements AnalyteValue {
  const factory _AnalyteValue(
      {required final String analyteCode,
      required final double value,
      required final String unit,
      final double? estimatedBG}) = _$AnalyteValueImpl;

  factory _AnalyteValue.fromJson(Map<String, dynamic> json) =
      _$AnalyteValueImpl.fromJson;

  @override
  String get analyteCode;
  @override // "TG" | "Na" | "K" | "Cl" | "Chol"
  double get value;
  @override
  String get unit;
  @override
  double? get estimatedBG;
  @override
  @JsonKey(ignore: true)
  _$$AnalyteValueImplCopyWith<_$AnalyteValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
