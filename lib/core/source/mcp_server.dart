import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:health/health.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  late WebSocketChannel webSocketChannel;

  /// Whether the health client has been configured
  bool _isHealthConfigured = false;

  bool _isConnected = false;

  final String _backendUrl = 'wss://vytallink.local.xmartlabs.com/ws/phone';

  /// Callback for when a connection code is received
  void Function(String code, String word, String message)? _onConnectionCodeReceived;

  /// Sets the callback for connection code events
  void setConnectionCodeCallback(
    void Function(String code, String word, String message) callback,
  ) {
    _onConnectionCodeReceived = callback;
  }

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

  Future<void> stop() async {
    if (_isConnected) {
      await webSocketChannel.sink.close();
      _isConnected = false;
    }
  }

  Future<void> connectToBackend() async {
    try {
      print('Connecting to backend at: $_backendUrl');

      webSocketChannel = IOWebSocketChannel.connect(Uri.parse(_backendUrl));
      _isConnected = true;

      // Listen for messages from backend
      webSocketChannel.stream.listen(
        (data) {
          print('Received from backend: $data');
          handleBackendMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );

      print('Connected to backend successfully');
    } catch (e) {
      print('Failed to connect to backend: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> sendToBackend(Map<String, dynamic> message) async {
    if (!_isConnected) {
      throw Exception('Not connected to backend');
    }

    final jsonMessage = jsonEncode(message);
    webSocketChannel.sink.add(jsonMessage);
    print('Sent to backend: $jsonMessage');
  }

  Future<void> handleBackendMessage(dynamic data) async {
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      print('Processing backend message: $message');

      // Handle different message types from backend
      switch (message['type']) {
        case 'health_data_request':
          final data2 = await handleHealthDataRequest(message);

          await sendToBackend({
            'type': 'response_metric',
            'data': data2,
            'requestId': message['requestId'],
            'timestamp': DateTime.now().toIso8601String(),
          });
          break;
        case 'connection_code':
          // Handle connection code for pairing
          final code = message['code'];
          final word = message['word'];
          final codeMessage = message['message'];
          print('Received connection code: $word $code');

          // Notify about the connection code (you can add a callback here)
          _onConnectionCodeReceived?.call(code, word, codeMessage);
          break;
        case 'error':
          print('Backend error: ${message['error']}');
          break;
        case 'ping':
          // Respond to ping (echo requestId if present)
          await sendToBackend({
            'type': 'pong',
            'requestId': message['requestId'],
            'timestamp': DateTime.now().toIso8601String(),
          });
          break;
        default:
          print('Unknown message type: ${message['type']}');
      }
    } catch (e) {
      print('Error processing backend message: $e');
    }
  }

  /// Parses health data type from string
  HealthDataType parseHealthDataType(String valueTypeStr) {
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
  void validateTimeRange(DateTime startTime, DateTime endTime) {
    if (startTime.isAfter(endTime)) {
      throw const HealthMcpServerException(
        'Start time must be before end time',
      );
    }
  }

  /// Checks if Google Health Connect is available on Android
  Future<void> checkHealthConnectAvailability() async {
    final isAvailable = await _healthClient.isHealthConnectAvailable();

    if (!isAvailable) {
      throw const HealthDataUnavailableException(
        // ignore: lines_longer_than_80_chars
        'Google Health Connect is not available on this device. Please install it from the Play Store.',
      );
    }
  }

  /// Requests health permissions from the user
  Future<void> requestHealthPermissions(
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
  Future<void> ensureHistoryAuthorizationIfNeeded() async {
    final isAuthorized = await _healthClient.isHealthDataHistoryAuthorized();

    if (!isAuthorized) {
      await _healthClient.requestHealthDataHistoryAuthorization();
    }
  }

  /// Ensures health permissions are granted for the specified types
  Future<void> ensureHealthPermissions(
    List<HealthDataType> healthTypes,
  ) async {
    if (Platform.isAndroid) {
      await checkHealthConnectAvailability();
    }

    final bool hasPermissions = await _healthClient.hasPermissions(
          healthTypes,
          permissions: [HealthDataAccess.READ],
        ) ??
        false;

    if (!hasPermissions) {
      await requestHealthPermissions(healthTypes);
    }

    await ensureHistoryAuthorizationIfNeeded();
  }

  /// Creates a steps data point
  HealthDataPoint createStepsDataPoint(
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

  /// Fetches health data points for the specified type and time range
  Future<List<HealthDataPoint>> fetchHealthDataPoints(
    HealthDataType valueType,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final List<HealthDataPoint> result = [];

    if (valueType == HealthDataType.STEPS) {
      final steps = await _healthClient.getTotalStepsInInterval(startTime, endTime);
      result.add(createStepsDataPoint(steps ?? 0, startTime, endTime));
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

  /// Formats health values for JSON serialization
  dynamic formatHealthValue(HealthValue value) {
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

  /// Formats health data points to JSON-serializable format
  List<Map<String, dynamic>> formatHealthDataPoints(
    List<HealthDataPoint> dataPoints,
  ) =>
      dataPoints
          .map(
            (dataPoint) => {
              'type': dataPoint.type.name,
              'value': formatHealthValue(dataPoint.value),
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

  /// Retrieves health data based on the provided arguments
  Future<List<Map<String, dynamic>>> retrieveHealthData(
    Map<String, dynamic> args,
  ) async {
    final String valueTypeStr = args['value_type'];
    final String startTimeString = args['startTime'];
    final String endTimeString = args['endTime'];

    final HealthDataType valueType = parseHealthDataType(valueTypeStr);
    final DateTime startTime = DateTime.parse(startTimeString);
    final DateTime endTime = DateTime.parse(endTimeString);

    validateTimeRange(startTime, endTime);
    await ensureHealthPermissions([valueType]);

    final List<HealthDataPoint> healthDataPoints =
        await fetchHealthDataPoints(valueType, startTime, endTime);

    return formatHealthDataPoints(healthDataPoints);
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

  /// Builds a success payload for WebSocket clients
  Map<String, dynamic> createSuccessResponse(
    List<Map<String, dynamic>> healthData,
    Map<String, dynamic> args,
  ) =>
      {
        'success': true,
        'count': healthData.length,
        'healthData': healthData,
        'value_type': args['value_type'],
        'startTime': args['startTime'],
        'endTime': args['endTime'],
      };

  /// Builds an error payload for WebSocket clients
  Map<String, dynamic> createErrorResponse(Object error) => {
        'success': false,
        'error_message': 'Error retrieving health data: ${error.toString()}',
      };

  /// Handles health data requests for WebSocket messages
  Future<Map<String, dynamic>> handleHealthDataRequest(
    Map<String, dynamic> args,
  ) async {
    try {
      final healthData = await retrieveHealthData(args['payload']);
      return createSuccessResponse(healthData, args);
    } catch (e) {
      return createErrorResponse(e);
    }
  }
}
