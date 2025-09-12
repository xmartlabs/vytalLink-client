import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_template/core/model/health_data_point.dart';

part 'health_data_response.freezed.dart';
part 'health_data_response.g.dart';

@freezed
class HealthDataResponse with _$HealthDataResponse {
  const factory HealthDataResponse({
    required bool success,
    required int count,
    required List<AppHealthDataPoint> healthData,
    @JsonKey(name: 'value_type') required String valueType,
    required String startTime,
    required String endTime,
    String? groupBy,
    bool? isAggregated,
    String? statisticType,
  }) = _HealthDataResponse;

  factory HealthDataResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthDataResponseFromJson(json);
}

@freezed
class AggregatedHealthDataResponse with _$AggregatedHealthDataResponse {
  const factory AggregatedHealthDataResponse({
    required bool success,
    required int count,
    required List<AggregatedHealthDataPoint> healthData,
    @JsonKey(name: 'value_type') required String valueType,
    required String startTime,
    required String endTime,
    String? groupBy,
    bool? isAggregated,
    String? statisticType,
  }) = _AggregatedHealthDataResponse;

  factory AggregatedHealthDataResponse.fromJson(Map<String, dynamic> json) =>
      _$AggregatedHealthDataResponseFromJson(json);
}

@freezed
class HealthDataErrorResponse with _$HealthDataErrorResponse {
  const factory HealthDataErrorResponse({
    required bool success,
    @JsonKey(name: 'error_message') required String errorMessage,
  }) = _HealthDataErrorResponse;

  factory HealthDataErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthDataErrorResponseFromJson(json);
}
