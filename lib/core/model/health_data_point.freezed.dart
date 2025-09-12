// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_data_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppHealthDataPoint _$AppHealthDataPointFromJson(Map<String, dynamic> json) {
  return _AppHealthDataPoint.fromJson(json);
}

/// @nodoc
mixin _$AppHealthDataPoint {
  String get type => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String get dateFrom => throw _privateConstructorUsedError;
  String get dateTo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppHealthDataPointCopyWith<AppHealthDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppHealthDataPointCopyWith<$Res> {
  factory $AppHealthDataPointCopyWith(
          AppHealthDataPoint value, $Res Function(AppHealthDataPoint) then) =
      _$AppHealthDataPointCopyWithImpl<$Res, AppHealthDataPoint>;
  @useResult
  $Res call(
      {String type,
      dynamic value,
      String unit,
      String dateFrom,
      String dateTo});
}

/// @nodoc
class _$AppHealthDataPointCopyWithImpl<$Res, $Val extends AppHealthDataPoint>
    implements $AppHealthDataPointCopyWith<$Res> {
  _$AppHealthDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = freezed,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppHealthDataPointImplCopyWith<$Res>
    implements $AppHealthDataPointCopyWith<$Res> {
  factory _$$AppHealthDataPointImplCopyWith(_$AppHealthDataPointImpl value,
          $Res Function(_$AppHealthDataPointImpl) then) =
      __$$AppHealthDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      dynamic value,
      String unit,
      String dateFrom,
      String dateTo});
}

/// @nodoc
class __$$AppHealthDataPointImplCopyWithImpl<$Res>
    extends _$AppHealthDataPointCopyWithImpl<$Res, _$AppHealthDataPointImpl>
    implements _$$AppHealthDataPointImplCopyWith<$Res> {
  __$$AppHealthDataPointImplCopyWithImpl(_$AppHealthDataPointImpl _value,
      $Res Function(_$AppHealthDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = freezed,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
  }) {
    return _then(_$AppHealthDataPointImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppHealthDataPointImpl implements _AppHealthDataPoint {
  const _$AppHealthDataPointImpl(
      {required this.type,
      required this.value,
      required this.unit,
      required this.dateFrom,
      required this.dateTo});

  factory _$AppHealthDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppHealthDataPointImplFromJson(json);

  @override
  final String type;
  @override
  final dynamic value;
  @override
  final String unit;
  @override
  final String dateFrom;
  @override
  final String dateTo;

  @override
  String toString() {
    return 'AppHealthDataPoint(type: $type, value: $value, unit: $unit, dateFrom: $dateFrom, dateTo: $dateTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppHealthDataPointImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type,
      const DeepCollectionEquality().hash(value), unit, dateFrom, dateTo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppHealthDataPointImplCopyWith<_$AppHealthDataPointImpl> get copyWith =>
      __$$AppHealthDataPointImplCopyWithImpl<_$AppHealthDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppHealthDataPointImplToJson(
      this,
    );
  }
}

abstract class _AppHealthDataPoint implements AppHealthDataPoint {
  const factory _AppHealthDataPoint(
      {required final String type,
      required final dynamic value,
      required final String unit,
      required final String dateFrom,
      required final String dateTo}) = _$AppHealthDataPointImpl;

  factory _AppHealthDataPoint.fromJson(Map<String, dynamic> json) =
      _$AppHealthDataPointImpl.fromJson;

  @override
  String get type;
  @override
  dynamic get value;
  @override
  String get unit;
  @override
  String get dateFrom;
  @override
  String get dateTo;
  @override
  @JsonKey(ignore: true)
  _$$AppHealthDataPointImplCopyWith<_$AppHealthDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AggregatedHealthDataPoint _$AggregatedHealthDataPointFromJson(
    Map<String, dynamic> json) {
  return _AggregatedHealthDataPoint.fromJson(json);
}

/// @nodoc
mixin _$AggregatedHealthDataPoint {
  String get type => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String get dateFrom => throw _privateConstructorUsedError;
  String get dateTo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AggregatedHealthDataPointCopyWith<AggregatedHealthDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AggregatedHealthDataPointCopyWith<$Res> {
  factory $AggregatedHealthDataPointCopyWith(AggregatedHealthDataPoint value,
          $Res Function(AggregatedHealthDataPoint) then) =
      _$AggregatedHealthDataPointCopyWithImpl<$Res, AggregatedHealthDataPoint>;
  @useResult
  $Res call(
      {String type, double value, String unit, String dateFrom, String dateTo});
}

/// @nodoc
class _$AggregatedHealthDataPointCopyWithImpl<$Res,
        $Val extends AggregatedHealthDataPoint>
    implements $AggregatedHealthDataPointCopyWith<$Res> {
  _$AggregatedHealthDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AggregatedHealthDataPointImplCopyWith<$Res>
    implements $AggregatedHealthDataPointCopyWith<$Res> {
  factory _$$AggregatedHealthDataPointImplCopyWith(
          _$AggregatedHealthDataPointImpl value,
          $Res Function(_$AggregatedHealthDataPointImpl) then) =
      __$$AggregatedHealthDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type, double value, String unit, String dateFrom, String dateTo});
}

/// @nodoc
class __$$AggregatedHealthDataPointImplCopyWithImpl<$Res>
    extends _$AggregatedHealthDataPointCopyWithImpl<$Res,
        _$AggregatedHealthDataPointImpl>
    implements _$$AggregatedHealthDataPointImplCopyWith<$Res> {
  __$$AggregatedHealthDataPointImplCopyWithImpl(
      _$AggregatedHealthDataPointImpl _value,
      $Res Function(_$AggregatedHealthDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
  }) {
    return _then(_$AggregatedHealthDataPointImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as String,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AggregatedHealthDataPointImpl implements _AggregatedHealthDataPoint {
  const _$AggregatedHealthDataPointImpl(
      {required this.type,
      required this.value,
      required this.unit,
      required this.dateFrom,
      required this.dateTo});

  factory _$AggregatedHealthDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$AggregatedHealthDataPointImplFromJson(json);

  @override
  final String type;
  @override
  final double value;
  @override
  final String unit;
  @override
  final String dateFrom;
  @override
  final String dateTo;

  @override
  String toString() {
    return 'AggregatedHealthDataPoint(type: $type, value: $value, unit: $unit, dateFrom: $dateFrom, dateTo: $dateTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AggregatedHealthDataPointImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, value, unit, dateFrom, dateTo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AggregatedHealthDataPointImplCopyWith<_$AggregatedHealthDataPointImpl>
      get copyWith => __$$AggregatedHealthDataPointImplCopyWithImpl<
          _$AggregatedHealthDataPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AggregatedHealthDataPointImplToJson(
      this,
    );
  }
}

abstract class _AggregatedHealthDataPoint implements AggregatedHealthDataPoint {
  const factory _AggregatedHealthDataPoint(
      {required final String type,
      required final double value,
      required final String unit,
      required final String dateFrom,
      required final String dateTo}) = _$AggregatedHealthDataPointImpl;

  factory _AggregatedHealthDataPoint.fromJson(Map<String, dynamic> json) =
      _$AggregatedHealthDataPointImpl.fromJson;

  @override
  String get type;
  @override
  double get value;
  @override
  String get unit;
  @override
  String get dateFrom;
  @override
  String get dateTo;
  @override
  @JsonKey(ignore: true)
  _$$AggregatedHealthDataPointImplCopyWith<_$AggregatedHealthDataPointImpl>
      get copyWith => throw _privateConstructorUsedError;
}
