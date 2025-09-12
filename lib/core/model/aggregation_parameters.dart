import 'package:flutter_template/core/model/health_data_point.dart';
import 'package:flutter_template/core/model/statistic_types.dart';
import 'package:flutter_template/core/model/time_group_by.dart';

class HealthDataAggregationParameters {
  const HealthDataAggregationParameters({
    required this.formattedData,
    required this.aggregatedData,
    required this.startTime,
    required this.endTime,
    required this.groupBy,
    required this.statisticType,
  });

  final List<AppHealthDataPoint> formattedData;
  final List<AggregatedHealthDataPoint> aggregatedData;
  final DateTime startTime;
  final DateTime endTime;
  final TimeGroupBy groupBy;
  final StatisticType statisticType;
}
