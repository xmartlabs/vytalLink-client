import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_data_point.freezed.dart';
part 'health_data_point.g.dart';

@freezed
class AppHealthDataPoint with _$AppHealthDataPoint {
  const factory AppHealthDataPoint({
    required String type,
    required dynamic value,
    required String unit,
    required String dateFrom,
    required String dateTo,
  }) = _AppHealthDataPoint;

  factory AppHealthDataPoint.fromJson(Map<String, dynamic> json) =>
      _$AppHealthDataPointFromJson(json);
}

@freezed
class AggregatedHealthDataPoint with _$AggregatedHealthDataPoint {
  const factory AggregatedHealthDataPoint({
    required String type,
    required double value,
    required String unit,
    required String dateFrom,
    required String dateTo,
  }) = _AggregatedHealthDataPoint;

  factory AggregatedHealthDataPoint.fromJson(Map<String, dynamic> json) =>
      _$AggregatedHealthDataPointFromJson(json);
}
