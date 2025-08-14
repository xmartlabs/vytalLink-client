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

const outputSchemaProperties = {
  "type": "object",
  "properties": {
    "healthData": {
      "type": "array",
      "description": "Array of health data points retrieved",
      "items": {
        "type": "object",
        "properties": {
          "uuid": {
            "type": "string",
            "description": "UUID of the data point",
          },
          "value": {
            "type": "object",
            "description": "The health value object with type-specific data",
            "properties": {
              "__type": {
                "type": "string",
                "description":
                    "Type of health value (NumericHealthValue, WorkoutHealthValue, etc.)",
              },
              "numeric_value": {
                "type": "number",
                "description": "Numeric value for basic health metrics",
              },
              "workout_activity_type": {
                "type": "string",
                "description": "Type of workout activity",
              },
              "total_energy_burned": {
                "type": "number",
                "description": "Total energy burned in workout",
              },
              "total_distance": {
                "type": "number",
                "description": "Total distance in workout",
              },
              "total_steps": {
                "type": "number",
                "description": "Total steps in workout",
              },
              "frequencies": {
                "type": "array",
                "description": "Audiogram frequencies",
                "items": {
                  "type": "number",
                },
              },
              "left_ear_sensitivities": {
                "type": "array",
                "description": "Left ear hearing sensitivities",
                "items": {
                  "type": "number",
                },
              },
              "right_ear_sensitivities": {
                "type": "array",
                "description": "Right ear hearing sensitivities",
                "items": {
                  "type": "number",
                },
              },
              "name": {
                "type": "string",
                "description": "Name of nutrition item",
              },
              "calories": {
                "type": "number",
                "description": "Calories in nutrition",
              },
              "protein": {
                "type": "number",
                "description": "Protein content in grams",
              },
              "fat": {
                "type": "number",
                "description": "Fat content in grams",
              },
              "carbs": {
                "type": "number",
                "description": "Carbohydrate content in grams",
              },
            },
            "required": ["__type"],
          },
          "type": {
            "type": "string",
            "description": "The health data type (e.g., STEPS, HEART_RATE)",
          },
          "unit": {
            "type": "string",
            "description":
                "Unit of measurement (e.g., COUNT, BEATS_PER_MINUTE)",
          },
          "date_from": {
            "type": "string",
            "description": "Start time of measurement (ISO 8601 format)",
          },
          "date_to": {
            "type": "string",
            "description": "End time of measurement (ISO 8601 format)",
          },
          "source_platform": {
            "type": "string",
            "description":
                "Health platform source (appleHealth or googleHealthConnect)",
          },
          "source_device_id": {
            "type": "string",
            "description": "ID of device that recorded the data",
          },
          "source_id": {
            "type": "string",
            "description": "ID of the source application",
          },
          "source_name": {
            "type": "string",
            "description": "Name of the source application",
          },
          "recording_method": {
            "type": "number",
            "description":
                "Recording method: 0=unknown, 1=active, 2=automatic, 3=manual",
          },
          "workout_summary": {
            "type": "object",
            "description": "Workout summary information if applicable",
            "properties": {
              "workout_type": {
                "type": "string",
                "description": "Type of workout",
              },
              "total_distance": {
                "type": "number",
                "description": "Total workout distance",
              },
              "total_energy_burned": {
                "type": "number",
                "description": "Total energy burned in workout",
              },
              "total_steps": {
                "type": "number",
                "description": "Total steps in workout",
              },
            },
          },
          "metadata": {
            "type": "object",
            "description": "Additional metadata as key-value pairs",
          },
          "device_model": {
            "type": "string",
            "description": "Device model (iOS only)",
          },
        },
        "required": [
          "uuid",
          "value",
          "type",
          "unit",
          "date_from",
          "date_to",
          "source_platform",
          "source_device_id",
          "source_id",
          "source_name",
          "recording_method",
        ],
      },
    },
    "count": {
      "type": "number",
      "description": "Total number of health data points returned",
    },
    "success": {
      "type": "boolean",
      "description": "Whether the operation completed successfully",
    },
    "error_message": {
      "type": "string",
      "description": "Error message if operation failed",
    },
  },
  "required": ["healthData", "count", "success"],
};
