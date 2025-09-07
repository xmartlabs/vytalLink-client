import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_template/core/common/logger.dart';
import 'package:health/health.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

class HealthMcpServerException implements Exception {
  const HealthMcpServerException(this.message, [this.cause]);

  final String message;
  final dynamic cause;

  @override
  String toString() => 'HealthMcpServerException: $message'
      '${cause != null ? ' (Cause: $cause)' : ''}';
}

class HealthPermissionException extends HealthMcpServerException {
  const HealthPermissionException(super.message, [super.cause]);
}

class HealthDataUnavailableException extends HealthMcpServerException {
  const HealthDataUnavailableException(super.message, [super.cause]);
}

class HealthMcpServerService {
  HealthMcpServerService({
    required this.config,
    Health? healthClient,
  }) : _healthClient = healthClient ?? Health();

  final HealthMcpServerConfig config;
  final Health _healthClient;

  late WebSocketChannel webSocketChannel;

  bool _isHealthConfigured = false;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  final Uri _backendUrl = Uri.parse('ws://192.168.1.19:8000/ws/phone');

  void Function(String code, String word, String message)?
      _onConnectionCodeReceived;
  void Function(String error)? _onConnectionError;

  void Function()? _onConnectionLost;

  void setConnectionCodeCallback(
    void Function(String code, String word, String message) callback,
  ) {
    _onConnectionCodeReceived = callback;
  }

  void setConnectionErrorCallback(
    void Function(String error) callback,
  ) {
    _onConnectionError = callback;
  }

  void setConnectionLostCallback(
    void Function() callback,
  ) {
    _onConnectionLost = callback;
  }

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
      Logger.d('Connecting to backend at: $_backendUrl');

      webSocketChannel = IOWebSocketChannel.connect(_backendUrl);
      _isConnected = true;

      webSocketChannel.stream.listen(
        (data) {
          handleBackendMessage(data);
        },
        onError: (error) {
          Logger.e('WebSocket error: $error');
          _isConnected = false;
          _onConnectionError?.call('Connection error: $error');
        },
        onDone: () {
          Logger.d('WebSocket connection closed');
          if (_isConnected) {
            _isConnected = false;
            _onConnectionLost?.call();
          }
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!_isConnected) {
        throw Exception('Connection failed - could not establish');
      }

      Logger.i('Connected to backend successfully');
    } catch (e) {
      Logger.e('Failed to connect to backend: $e');
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
    Logger.d('Sent to backend: $jsonMessage');
  }

  Future<void> handleBackendMessage(dynamic data) async {
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      Logger.d('Processing backend message: ${message['type']}');

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
          final code = message['code'];
          final word = message['word'];
          final codeMessage = message['message'];
          Logger.i('Received connection code: $word $code');

          _onConnectionCodeReceived?.call(code, word, codeMessage);
          break;
        case 'error':
          Logger.e('Backend error: ${message['error']}');
          break;
        case 'ping':
          await sendToBackend({
            'type': 'pong',
            'requestId': message['requestId'],
            'timestamp': DateTime.now().toIso8601String(),
          });
          break;
        default:
          Logger.w('Unknown message type: ${message['type']}');
      }
    } catch (e) {
      Logger.e('Error processing backend message: $e');
    }
  }

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

  void validateTimeRange(DateTime startTime, DateTime endTime) {
    if (startTime.isAfter(endTime)) {
      throw const HealthMcpServerException(
        'Start time must be before end time',
      );
    }
  }

  Future<void> checkHealthConnectAvailability() async {
    final isAvailable = await _healthClient.isHealthConnectAvailable();

    if (!isAvailable) {
      throw const HealthDataUnavailableException(
        'Google Health Connect is not available on this device. '
        'Please install it from the Play Store.',
      );
    }
  }

  Future<void> requestHealthPermissions(
    List<HealthDataType> healthTypes,
  ) async {
    final bool permissionsGranted = await _healthClient.requestAuthorization(
      healthTypes,
      permissions: [HealthDataAccess.READ],
    );

    if (!permissionsGranted) {
      throw const HealthPermissionException(
        'Health permissions not granted. '
        'Please open Health Connect app and grant permissions manually.',
      );
    }
  }

  Future<void> ensureHistoryAuthorizationIfNeeded() async {
    final isAuthorized = await _healthClient.isHealthDataHistoryAuthorized();

    if (!isAuthorized) {
      await _healthClient.requestHealthDataHistoryAuthorization();
    }
  }

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

  Future<List<HealthDataPoint>> fetchHealthDataPoints(
    HealthDataType valueType,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final List<HealthDataPoint> result = [];

    if (valueType == HealthDataType.STEPS) {
      final steps =
          await _healthClient.getTotalStepsInInterval(startTime, endTime);
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

  Map<String, dynamic> createErrorResponse(Object error) => {
        'success': false,
        'error_message': 'Error retrieving health data: ${error.toString()}',
      };

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
