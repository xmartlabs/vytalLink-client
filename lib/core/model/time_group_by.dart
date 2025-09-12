import 'package:freezed_annotation/freezed_annotation.dart';

enum TimeGroupBy {
  @JsonValue('hour')
  hour,

  @JsonValue('day')
  day,

  @JsonValue('week')
  week,

  @JsonValue('month')
  month;

  static TimeGroupBy fromString(String value) => switch (value.toLowerCase()) {
        'hour' => TimeGroupBy.hour,
        'day' => TimeGroupBy.day,
        'week' => TimeGroupBy.week,
        'month' => TimeGroupBy.month,
        _ => TimeGroupBy.day,
      };

  String get value => switch (this) {
        TimeGroupBy.hour => 'hour',
        TimeGroupBy.day => 'day',
        TimeGroupBy.week => 'week',
        TimeGroupBy.month => 'month',
      };
}
