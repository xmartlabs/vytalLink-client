// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthDataRequestImpl _$$HealthDataRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthDataRequestImpl(
      valueType: json['value_type'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      groupBy: json['group_by'] as String,
      statistic: json['statistic'] as String,
    );

Map<String, dynamic> _$$HealthDataRequestImplToJson(
        _$HealthDataRequestImpl instance) =>
    <String, dynamic>{
      'value_type': instance.valueType,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'group_by': instance.groupBy,
      'statistic': instance.statistic,
    };
