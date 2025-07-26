// health_mcp_server.dart
import 'package:mcp_dart/mcp_dart.dart';
import 'package:health/health.dart';

void main() async {
  McpServer server = McpServer(
    const Implementation(name: "health-data-server", version: "1.0.0"),
    options: const ServerOptions(
      capabilities: ServerCapabilities(
        tools: ServerCapabilitiesTools(),
      ),
    ),
  )

  ..tool(
    "getHealthDataFromTypes",
    description: 'Retrieve health data points from Apple Health or Google Health Connect for specified data types and time range',
    inputSchemaProperties: {
      'types': {
        'type': 'array',
        'description': 'List of health data types to retrieve',
        'items': {
          'type': 'string',
          'enum': [
            // Core health metrics
            'STEPS', 'HEART_RATE', 'BLOOD_PRESSURE_SYSTOLIC', 'BLOOD_PRESSURE_DIASTOLIC',
            'WEIGHT', 'HEIGHT', 'BODY_FAT_PERCENTAGE', 'BODY_MASS_INDEX',
            'BLOOD_GLUCOSE', 'BLOOD_OXYGEN', 'BODY_TEMPERATURE',
            
            // Activity metrics
            'ACTIVE_ENERGY_BURNED', 'BASAL_ENERGY_BURNED', 'DISTANCE_WALKING_RUNNING',
            'FLIGHTS_CLIMBED', 'EXERCISE_TIME', 'WORKOUT',
            
            // Sleep metrics
            'SLEEP_ASLEEP', 'SLEEP_AWAKE', 'SLEEP_DEEP', 'SLEEP_LIGHT', 'SLEEP_REM',
            'SLEEP_IN_BED', 'SLEEP_AWAKE_IN_BED', 'SLEEP_OUT_OF_BED', 'SLEEP_SESSION', 'SLEEP_UNKNOWN',
            
            // Nutrition
            'WATER', 'NUTRITION',
            
            // Heart metrics
            'RESTING_HEART_RATE', 'WALKING_HEART_RATE', 'HEART_RATE_VARIABILITY_SDNN',
            'HEART_RATE_VARIABILITY_RMSSD', 'HIGH_HEART_RATE_EVENT', 'LOW_HEART_RATE_EVENT',
            'IRREGULAR_HEART_RATE_EVENT',
            
            // Respiratory
            'RESPIRATORY_RATE',
            
            // And all other available types from the enum...
          ]
        }
      },
      'startTime': {
        'type': 'string',
        'format': 'date-time',
        'description': 'Start time for data retrieval (ISO 8601 format)'
      },
      'endTime': {
        'type': 'string',
        'format': 'date-time',
        'description': 'End time for data retrieval (ISO 8601 format)'
      },
      'recordingMethodsToFilter': {
        'type': 'array',
        'description': 'Optional filter for recording methods',
        'items': {
          'type': 'string',
          'enum': ['unknown', 'active', 'automatic', 'manual']
        },
        'default': []
      }
    },
    // inputSchemaRequired: ['types', 'startTime', 'endTime'],
    
    // Output Schema - HealthDataPoint structure
    outputSchemaProperties: {
      'healthData': {
        'type': 'array',
        'description': 'Array of health data points',
        'items': {
          'type': 'object',
          'properties': {
            'uuid': {
              'type': 'string',
              'description': 'UUID of the data point'
            },
            'value': {
              'type': 'object',
              'description': 'The health value (can be numeric, audiogram, workout, etc.)',
              'oneOf': [
                {
                  'type': 'object',
                  'properties': {
                    '__type': { 'type': 'string', 'const': 'NumericHealthValue' },
                    'numeric_value': { 'type': 'number' }
                  },
                  'required': ['__type', 'numeric_value']
                },
                {
                  'type': 'object',
                  'properties': {
                    '__type': { 'type': 'string', 'const': 'WorkoutHealthValue' },
                    'workout_activity_type': { 'type': 'string' },
                    'total_energy_burned': { 'type': 'number', 'nullable': true },
                    'total_energy_burned_unit': { 'type': 'string', 'nullable': true },
                    'total_distance': { 'type': 'number', 'nullable': true },
                    'total_distance_unit': { 'type': 'string', 'nullable': true },
                    'total_steps': { 'type': 'number', 'nullable': true },
                    'total_steps_unit': { 'type': 'string', 'nullable': true }
                  },
                  'required': ['__type', 'workout_activity_type']
                },
                {
                  'type': 'object',
                  'properties': {
                    '__type': { 'type': 'string', 'const': 'AudiogramHealthValue' },
                    'frequencies': { 'type': 'array', 'items': { 'type': 'number' } },
                    'left_ear_sensitivities': { 'type': 'array', 'items': { 'type': 'number' } },
                    'right_ear_sensitivities': { 'type': 'array', 'items': { 'type': 'number' } }
                  },
                  'required': ['__type', 'frequencies', 'left_ear_sensitivities', 'right_ear_sensitivities']
                },
                {
                  'type': 'object',
                  'properties': {
                    '__type': { 'type': 'string', 'const': 'NutritionHealthValue' },
                    'name': { 'type': 'string', 'nullable': true },
                    'meal_type': { 'type': 'string', 'nullable': true },
                    'calories': { 'type': 'number', 'nullable': true },
                    'protein': { 'type': 'number', 'nullable': true },
                    'fat': { 'type': 'number', 'nullable': true },
                    'carbs': { 'type': 'number', 'nullable': true },
                    // ... add all nutrition fields
                  },
                  'required': ['__type']
                },
                // Add other health value types as needed
              ]
            },
            'type': {
              'type': 'string',
              'description': 'The type of health data'
            },
            'unit': {
              'type': 'string',
              'description': 'The unit of measurement'
            },
            'date_from': {
              'type': 'string',
              'format': 'date-time',
              'description': 'Start time of the measurement'
            },
            'date_to': {
              'type': 'string',
              'format': 'date-time', 
              'description': 'End time of the measurement'
            },
            'source_platform': {
              'type': 'string',
              'enum': ['appleHealth', 'googleHealthConnect'],
              'description': 'The health platform source'
            },
            'source_device_id': {
              'type': 'string',
              'description': 'Device ID that recorded the data'
            },
            'source_id': {
              'type': 'string',
              'description': 'Source application or service ID'
            },
            'source_name': {
              'type': 'string',
              'description': 'Source application or service name'
            },
            'recording_method': {
              'type': 'integer',
              'enum': [0, 1, 2, 3],
              'description': 'How the data was recorded: 0=unknown, 1=active, 2=automatic, 3=manual'
            },
            'workout_summary': {
              'type': 'object',
              'nullable': true,
              'properties': {
                'workout_type': { 'type': 'string' },
                'total_distance': { 'type': 'number' },
                'total_energy_burned': { 'type': 'number' },
                'total_steps': { 'type': 'number' }
              },
              'description': 'Workout summary if applicable'
            },
            'metadata': {
              'type': 'object',
              'nullable': true,
              'additionalProperties': true,
              'description': 'Additional metadata for the data point'
            },
            'device_model': {
              'type': 'string',
              'nullable': true,
              'description': 'Device model (iOS only)'
            }
          },
          'required': [
            'uuid', 'value', 'type', 'unit', 'date_from', 'date_to',
            'source_platform', 'source_device_id', 'source_id', 'source_name', 'recording_method'
          ]
        }
      },
      'count': {
        'type': 'integer',
        'description': 'Total number of health data points returned'
      },
      'success': {
        'type': 'boolean',
        'description': 'Whether the operation was successful'
      },
      'error': {
        'type': 'string',
        'nullable': true,
        'description': 'Error message if the operation failed'
      }
    },
    
    callback: ({args, extra}) async {
      try {
        // Parse input parameters
        final List<String> typeStrings = List<String>.from(args!['types']);
        final DateTime startTime = DateTime.parse(args['startTime']);
        final DateTime endTime = DateTime.parse(args['endTime']);
        final List<String> recordingMethodStrings = 
            List<String>.from(args['recordingMethodsToFilter'] ?? []);

        // Convert string types to HealthDataType enum
        final List<HealthDataType> types = typeStrings
            .map((typeString) => HealthDataType.values
                .firstWhere((type) => type.name == typeString))
            .toList();

        // Convert recording method strings to enum
        final List<RecordingMethod> recordingMethods = recordingMethodStrings
            .map((methodString) => RecordingMethod.values
                .firstWhere((method) => method.name == methodString))
            .toList();

        // Create health instance and configure
        final health = Health();
        await health.configure();

        // Get health data
        final List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          types: types,
          startTime: startTime,
          endTime: endTime,
          recordingMethodsToFilter: recordingMethods,
        );

        // Convert to JSON
        final List<Map<String, dynamic>> healthDataJson = 
            healthData.map((point) => point.toJson()).toList();

        return CallToolResult(
          content: [
            TextContent(
              text: '''Health data retrieved successfully.

Total data points: ${healthData.length}
Time range: ${startTime.toIso8601String()} to ${endTime.toIso8601String()}
Data types: ${types.map((t) => t.name).join(', ')}

Data points:
${healthDataJson.map((data) => '- ${data['type']}: ${data['value']} ${data['unit']} (${data['date_from']})').take(10).join('\n')}
${healthData.length > 10 ? '\n... and ${healthData.length - 10} more' : ''}''',
            ),
          ],
          meta: {
            'healthData': healthDataJson,
            'count': healthData.length,
            'success': true,
            'error': null,
          },
        );

      } catch (error) {
        return CallToolResult(
          content: [
            TextContent(
              text: 'Error retrieving health data: $error',
            ),
          ],
          meta: {
            'healthData': [],
            'count': 0,
            'success': false,
            'error': error.toString(),
          },
        );
      }
    },
  )

  ..connect(StdioServerTransport());
}