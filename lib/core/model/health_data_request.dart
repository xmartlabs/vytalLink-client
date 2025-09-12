import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_template/core/model/statistic_types.dart';
import 'package:flutter_template/core/model/time_group_by.dart';
import 'package:health/health.dart';

part 'health_data_request.freezed.dart';
part 'health_data_request.g.dart';

@freezed
class HealthDataRequest with _$HealthDataRequest {
  const factory HealthDataRequest({
    required String valueType,
    @JsonKey(name: 'startTime') required String startTime,
    @JsonKey(name: 'endTime') required String endTime,
    required String groupBy,
    required String statistic,
  }) = _HealthDataRequest;

  factory HealthDataRequest.fromJson(Map<String, dynamic> json) =>
      _$HealthDataRequestFromJson(json);
}

extension HealthDataRequestX on HealthDataRequest {
  HealthDataType get parsedValueType => _parseHealthDataType(valueType);

  DateTime get parsedStartTime => DateTime.parse(startTime);

  DateTime get parsedEndTime => DateTime.parse(endTime);

  StatisticType get parsedStatisticType => StatisticType.fromString(statistic);

  TimeGroupBy get parsedGroupBy => TimeGroupBy.fromString(groupBy);
}

HealthDataType _parseHealthDataType(String valueTypeStr) {
  switch (valueTypeStr.toUpperCase()) {
    case 'HEART_RATE':
      return HealthDataType.HEART_RATE;
    case 'STEPS':
      return HealthDataType.STEPS;
    case 'WEIGHT':
      return HealthDataType.WEIGHT;
    case 'HEIGHT':
      return HealthDataType.HEIGHT;
    case 'ACTIVE_ENERGY_BURNED':
      return HealthDataType.ACTIVE_ENERGY_BURNED;
    case 'DISTANCE_DELTA':
      return HealthDataType.DISTANCE_DELTA;
    case 'BLOOD_PRESSURE_SYSTOLIC':
      return HealthDataType.BLOOD_PRESSURE_SYSTOLIC;
    case 'BLOOD_PRESSURE_DIASTOLIC':
      return HealthDataType.BLOOD_PRESSURE_DIASTOLIC;
    case 'BLOOD_GLUCOSE':
      return HealthDataType.BLOOD_GLUCOSE;
    case 'WATER':
      return HealthDataType.WATER;
    case 'SLEEP_SESSION':
      return HealthDataType.SLEEP_SESSION;
    case 'SLEEP_ASLEEP':
      return HealthDataType.SLEEP_ASLEEP;
    case 'SLEEP_AWAKE':
      return HealthDataType.SLEEP_AWAKE;
    case 'SLEEP_DEEP':
      return HealthDataType.SLEEP_DEEP;
    case 'SLEEP_LIGHT':
      return HealthDataType.SLEEP_LIGHT;
    case 'SLEEP_REM':
      return HealthDataType.SLEEP_REM;
    case 'WORKOUT':
      return HealthDataType.WORKOUT;
    default:
      throw ArgumentError('Unknown health data type: $valueTypeStr');
  }
}
