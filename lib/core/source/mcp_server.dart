import 'dart:io';

import 'package:flutter_template/core/source/mcp_schema.dart';
import 'package:health/health.dart';
import 'package:mcp_server/mcp_server.dart';

/// Configuration class for the Health MCP Server
class HealthMcpServerConfig {
  const HealthMcpServerConfig({
    required this.serverName,
    required this.serverVersion,
    required this.host,
    required this.port,
    required this.endpoint,
    this.isJsonResponseEnabled = true,
  });

  final String serverName;
  final String serverVersion;
  final String host;
  final int port;
  final String endpoint;
  final bool isJsonResponseEnabled;
}

/// Custom exceptions for the Health MCP Server
class HealthMcpServerException implements Exception {
  const HealthMcpServerException(this.message, [this.cause]);

  final String message;
  final dynamic cause;

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'HealthMcpServerException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class HealthPermissionException extends HealthMcpServerException {
  const HealthPermissionException(super.message, [super.cause]);
}

class HealthDataUnavailableException extends HealthMcpServerException {
  const HealthDataUnavailableException(super.message, [super.cause]);
}

/// A service that provides health data through an MCP (Model Context Protocol)
/// server.
///
/// This service integrates with Apple HealthKit and Google Health Connect to
/// retrieve health data and expose it through an MCP server interface.
///
/// Example usage:
/// ```dart
/// final healthServer = HealthMcpServerService(
///   config: HealthMcpServerConfig(
///     serverName: 'My Health MCP Server',
///     serverVersion: '1.0.0',
///     host: 'localhost',
///     port: 8080,
///     endpoint: '/mcp',
///   ),
/// );
///
/// await healthServer.initialize();
/// final server = await healthServer.start();
/// ```
class HealthMcpServerService {
  /// Creates a new instance of the Health MCP Server Service.
  HealthMcpServerService({
    required this.config,
    Health? healthClient,
  }) : _healthClient = healthClient ?? Health();

  /// The configuration for this server instance
  final HealthMcpServerConfig config;

  /// The health client instance for accessing health data
  final Health _healthClient;

  /// The MCP server instance (null if not started)
  Server? _mcpServer;

  /// Whether the health client has been configured
  bool _isHealthConfigured = false;

  /// Gets the current MCP server instance
  ///
  /// Throws [StateError] if the server has not been started yet.
  Server get mcpServer {
    if (_mcpServer == null) {
      throw StateError('MCP server has not been started. Call start() first.');
    }
    return _mcpServer!;
  }

  /// Whether the server is currently running
  bool get isRunning => _mcpServer != null;

  /// Initializes the health client configuration
  ///
  /// This should be called before starting the server to ensure
  /// the health client is properly configured.
  Future<void> initialize() async {
    if (_isHealthConfigured) return;

    try {
      await _healthClient.configure();
      _isHealthConfigured = true;
    } catch (e) {
      throw HealthMcpServerException(
        'Failed to configure health client',
        e,
      );
    }
  }

  /// Stops the MCP server and cleans up resources
  ///
  /// Returns `true` if the server was successfully stopped,
  /// `false` if it was already stopped.
  Future<bool> stop() async {
    if (_mcpServer == null) return false;

    try {
      _mcpServer!.disconnect();
      _mcpServer = null;
      return true;
    } catch (e) {
      throw HealthMcpServerException(
        'Failed to stop MCP server',
        e,
      );
    }
  }

  /// Starts the MCP server with health data tools
  ///
  /// Returns the configured and running [Server] instance.
  /// Throws [HealthMcpServerException] if server fails to start.
  Future<Server> start() async {
    if (_mcpServer != null) {
      throw StateError('Server is already running. Call stop() first.');
    }

    if (!_isHealthConfigured) {
      await initialize();
    }

    try {
      final server = await McpServer.createAndStart(
        config: McpServer.simpleConfig(
          name: config.serverName,
          version: config.serverVersion,
        ),
        transportConfig: TransportConfig.streamableHttp(
          host: config.host,
          port: config.port,
          endpoint: config.endpoint,
          isJsonResponseEnabled: config.isJsonResponseEnabled,
        ),
      ).then((server) => server.successOrNull!);

      _registerHealthDataTool(server);
      _mcpServer = server;

      return server;
    } catch (e) {
      throw HealthMcpServerException(
        'Failed to start MCP server',
        e,
      );
    }
  }

  /// Registers the health data tool with the MCP server
  void _registerHealthDataTool(Server server) {
    server.addTool(
      name: "get_health_data",
      description:
          // ignore: lines_longer_than_80_chars
          'Retrieve health data from Apple HealthKit or Google Health Connect for specified data types and time range',
      inputSchema: inputSchema,
      handler: (args) => _handleHealthDataRequest(args),
    );
  }

  /// Handles health data requests from the MCP server
  Future<CallToolResult> _handleHealthDataRequest(
    Map<String, dynamic> args,
  ) async {
    try {
      final healthData = await _retrieveHealthData(args);
      return _createSuccessResponse(healthData, args);
    } catch (e) {
      return _createErrorResponse(e);
    }
  }

  /// Retrieves health data based on the provided arguments
  Future<List<Map<String, dynamic>>> _retrieveHealthData(
    Map<String, dynamic> args,
  ) async {
    final String valueTypeStr = args['value_type'];
    final String startTimeString = args['startTime'];
    final String endTimeString = args['endTime'];

    final HealthDataType valueType = _parseHealthDataType(valueTypeStr);
    final DateTime startTime = DateTime.parse(startTimeString);
    final DateTime endTime = DateTime.parse(endTimeString);

    _validateTimeRange(startTime, endTime);
    await _ensureHealthPermissions([valueType]);

    final List<HealthDataPoint> healthDataPoints =
        await _fetchHealthDataPoints(valueType, startTime, endTime);

    return _formatHealthDataPoints(healthDataPoints);
  }

  /// Parses health data type from string
  HealthDataType _parseHealthDataType(String valueTypeStr) {
    try {
      return HealthDataType.values.firstWhere(
        (type) => type.name == valueTypeStr,
      );
    } catch (e) {
      throw HealthMcpServerException(
        'Invalid health data type: $valueTypeStr',
        e,
      );
    }
  }

  /// Validates that start time is before end time
  void _validateTimeRange(DateTime startTime, DateTime endTime) {
    if (startTime.isAfter(endTime)) {
      throw const HealthMcpServerException(
        'Start time must be before end time',
      );
    }
  }

  /// Ensures health permissions are granted for the specified types
  Future<void> _ensureHealthPermissions(
    List<HealthDataType> healthTypes,
  ) async {
    if (Platform.isAndroid) {
      await _checkHealthConnectAvailability();
    }

    final bool hasPermissions = await _healthClient.hasPermissions(
          healthTypes,
          permissions: [HealthDataAccess.READ],
        ) ??
        false;

    if (!hasPermissions) {
      await _requestHealthPermissions(healthTypes);
    }

    await _ensureHistoryAuthorizationIfNeeded();
  }

  /// Checks if Google Health Connect is available on Android
  Future<void> _checkHealthConnectAvailability() async {
    final isAvailable = await _healthClient.isHealthConnectAvailable();

    if (!isAvailable) {
      throw const HealthDataUnavailableException(
        // ignore: lines_longer_than_80_chars
        'Google Health Connect is not available on this device. Please install it from the Play Store.',
      );
    }
  }

  /// Requests health permissions from the user
  Future<void> _requestHealthPermissions(
    List<HealthDataType> healthTypes,
  ) async {
    final bool permissionsGranted = await _healthClient.requestAuthorization(
      healthTypes,
      permissions: [HealthDataAccess.READ],
    );

    if (!permissionsGranted) {
      throw const HealthPermissionException(
        // ignore: lines_longer_than_80_chars
        'Health permissions not granted. Please open Health Connect app and grant permissions manually.',
      );
    }
  }

  /// Ensures health data history authorization if needed
  Future<void> _ensureHistoryAuthorizationIfNeeded() async {
    final isAuthorized = await _healthClient.isHealthDataHistoryAuthorized();

    if (!isAuthorized) {
      await _healthClient.requestHealthDataHistoryAuthorization();
    }
  }

  /// Fetches health data points for the specified type and time range
  Future<List<HealthDataPoint>> _fetchHealthDataPoints(
    HealthDataType valueType,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final List<HealthDataPoint> result = [];

    if (valueType == HealthDataType.STEPS) {
      final steps =
          await _healthClient.getTotalStepsInInterval(startTime, endTime);
      result.add(_createStepsDataPoint(steps ?? 0, startTime, endTime));
    } else {
      final healthData = await _healthClient.getHealthDataFromTypes(
        types: [valueType],
        startTime: startTime,
        endTime: endTime,
      );
      result.addAll(healthData);
    }

    return result;
  }

  /// Creates a steps data point
  HealthDataPoint _createStepsDataPoint(
    int steps,
    DateTime startTime,
    DateTime endTime,
  ) =>
      HealthDataPoint(
        type: HealthDataType.STEPS,
        value: NumericHealthValue(numericValue: steps),
        dateFrom: startTime,
        dateTo: endTime,
        uuid: '',
        unit: HealthDataUnit.COUNT,
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: '',
        sourceId: '',
        sourceName: '',
      );

  /// Formats health data points to JSON-serializable format
  List<Map<String, dynamic>> _formatHealthDataPoints(
    List<HealthDataPoint> dataPoints,
  ) =>
      dataPoints
          .map(
            (dataPoint) => {
              'type': dataPoint.type.name,
              'value': _formatHealthValue(dataPoint.value),
              'unit': dataPoint.unit.name,
              'dateFrom': dataPoint.dateFrom.toIso8601String(),
              'dateTo': dataPoint.dateTo.toIso8601String(),
              'sourcePlatform': dataPoint.sourcePlatform.name,
              'sourceDeviceId': dataPoint.sourceDeviceId,
              'sourceId': dataPoint.sourceId,
              'sourceName': dataPoint.sourceName,
            },
          )
          .toList();

  /// Creates a success response for the MCP server
  CallToolResult _createSuccessResponse(
    List<Map<String, dynamic>> healthData,
    Map<String, dynamic> args,
  ) {
    final startTime = DateTime.parse(args['startTime']);
    final endTime = DateTime.parse(args['endTime']);
    final valueType = args['value_type'];

    return CallToolResult(
      content: [
        TextContent(
          text: '''Health Data Retrieved Successfully

Total data points: ${healthData.length}
Time range: ${startTime.toIso8601String()} to ${endTime.toIso8601String()}
Type requested: $valueType

Data:
${_formatDataForDisplay(healthData)}''',
        ),
      ],
    );
  }

  /// Creates an error response for the MCP server
  CallToolResult _createErrorResponse(Object error) => CallToolResult(
        content: [
          TextContent(
            text: 'Error retrieving health data: ${error.toString()}',
          ),
        ],
        isError: true,
      );

  /// Formats health values for JSON serialization
  dynamic _formatHealthValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue;
    } else if (value is WorkoutHealthValue) {
      return {
        'workoutActivityType': value.workoutActivityType.name,
        'totalEnergyBurned': value.totalEnergyBurned,
        'totalDistance': value.totalDistance,
      };
    } else if (value is NutritionHealthValue) {
      return {
        'calories': value.calories,
        'protein': value.protein,
        'carbs': value.carbs,
        'fat': value.fat,
      };
    }
    return value.toString();
  }

  /// Formats health data for display in the response
  String _formatDataForDisplay(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return 'No data found for the specified criteria';
    }

    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (final point in data) {
      final String type = point['type'];
      groupedData.putIfAbsent(type, () => []).add(point);
    }

    final StringBuffer buffer = StringBuffer();

    groupedData.forEach((type, points) {
      buffer.writeln('\n$type (${points.length} data points):');

      final int displayCount = points.length > 5 ? 5 : points.length;

      for (int i = 0; i < displayCount; i++) {
        final point = points[i];
        buffer
          ..writeln('  - Value: ${point['value']} ${point['unit']}')
          ..writeln('    Date: ${point['dateFrom']}')
          ..writeln('    Source: ${point['sourceName']}');
      }

      if (points.length > 5) {
        buffer.writeln('  ... and ${points.length - 5} more data points');
      }
    });

    return buffer.toString();
  }
}
