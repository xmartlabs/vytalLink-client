// ignore_for_file: lines_longer_than_80_chars

import 'package:health/health.dart';

// final _types = Platform.isAndroid ? dataTypeKeysAndroid : dataTypeKeysIOS;
const List<HealthDataType> _types = [
  HealthDataType.HEART_RATE,
  HealthDataType.STEPS,
  HealthDataType.DISTANCE_DELTA,
  HealthDataType.SPEED,
  HealthDataType.SLEEP_SESSION,
  HealthDataType.WORKOUT,
  HealthDataType.RESTING_HEART_RATE,
  HealthDataType.TOTAL_CALORIES_BURNED,
];

final inputSchema = {
  "type": "object",
  "properties": {
    "value_type": {
      "description": "Health data type to retrieve",
      "type": "string",
      "enum": _types.map((type) => type.name).toList(),
    },
    "startTime": {
      "type": "string",
      "format": "date-time",
      "description":
          "Start time for data retrieval in ISO 8601 format (e.g., '2024-01-01T00:00:00Z')",
    },
    "endTime": {
      "type": "string",
      "format": "date-time",
      "description":
          "End time for data retrieval in ISO 8601 format (e.g., '2024-01-02T00:00:00Z')",
    },
  },
  "required": ["value_type", "startTime", "endTime"],
};
