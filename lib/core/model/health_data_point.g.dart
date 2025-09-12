// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppHealthDataPointImpl _$$AppHealthDataPointImplFromJson(
        Map<String, dynamic> json) =>
    _$AppHealthDataPointImpl(
      type: json['type'] as String,
      value: json['value'],
      unit: json['unit'] as String,
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
    );

Map<String, dynamic> _$$AppHealthDataPointImplToJson(
        _$AppHealthDataPointImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'unit': instance.unit,
      'date_from': instance.dateFrom,
      'date_to': instance.dateTo,
    };

_$AggregatedHealthDataPointImpl _$$AggregatedHealthDataPointImplFromJson(
        Map<String, dynamic> json) =>
    _$AggregatedHealthDataPointImpl(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      dateFrom: json['date_from'] as String,
      dateTo: json['date_to'] as String,
    );

Map<String, dynamic> _$$AggregatedHealthDataPointImplToJson(
        _$AggregatedHealthDataPointImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'unit': instance.unit,
      'date_from': instance.dateFrom,
      'date_to': instance.dateTo,
    };
