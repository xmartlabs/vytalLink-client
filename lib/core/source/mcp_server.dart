import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_template/core/common/config.dart';
import 'package:flutter_template/core/common/logger.dart';
import 'package:health/health.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum StatisticsType {
  count('COUNT'),
  average('AVERAGE');

  const StatisticsType(this.value);
  final String value;

  static StatisticsType fromString(String value) =>
      StatisticsType.values.firstWhere(
        (type) => type.value == value.toUpperCase(),
        orElse: () => throw ArgumentError('Invalid statistics type: $value'),
      );
}

class HealthDataAggregationParameters {
  const HealthDataAggregationParameters({
    required this.formattedData,
    required this.aggregatedData,
    required this.startTime,
    required this.endTime,
    required this.groupBy,
    required this.statisticsType,
  });

  final List<Map<String, dynamic>> formattedData;
  final List<Map<String, dynamic>> aggregatedData;
  final DateTime startTime;
  final DateTime endTime;
  final String groupBy;
  final StatisticsType statisticsType;
}

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

  Health get healthClient => _healthClient;

  final Uri _backendUrl = Uri.parse(Config.wsUrl);

  // ignore: lines_longer_than_80_chars
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

    final healthData = await _healthClient.getHealthDataFromTypes(
      types: [valueType],
      startTime: startTime,
      endTime: endTime,
    );
    result.addAll(healthData);

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

  /// Retrieves health data based on the provided arguments
  ///
  /// Args can include:
  /// - value_type: The type of health data to retrieve
  /// - startTime: Start time in ISO8601 format
  /// - endTime: End time in ISO8601 format
  /// - groupBy: Optional. Time period for data aggregation:
  ///   - 'hour': Aggregate data by hour
  ///   - 'day': Aggregate data by day
  ///   - 'week': Aggregate data by week (Monday to Sunday)
  ///   - 'month': Aggregate data by month
  ///   - null/empty: Return raw data points without aggregation
  /// - statics: Optional. Statistics type:
  ///   - 'COUNT': Return count/sum of data points
  ///   - 'AVERAGE': Return average of data points
  Future<List<Map<String, dynamic>>> retrieveHealthData(
    Map<String, dynamic> args,
  ) async {
    final String valueTypeStr = args['value_type'];
    final String startTimeString = args['startTime'];
    final String endTimeString = args['endTime'];
    final String groupBy = args['group_by'];
    final String staticsStr = args['statics'];

    final HealthDataType valueType = parseHealthDataType(valueTypeStr);
    final DateTime startTime = DateTime.parse(startTimeString);
    final DateTime endTime = DateTime.parse(endTimeString);
    final StatisticsType statisticsType = StatisticsType.fromString(staticsStr);

    validateTimeRange(startTime, endTime);
    await ensureHealthPermissions([valueType]);

    final List<HealthDataPoint> healthDataPoints =
        await fetchHealthDataPoints(valueType, startTime, endTime);

    final formattedData = formatHealthDataPoints(healthDataPoints);

    final aggregatedData = _aggregateHealthData(
      formattedData,
      groupBy,
      startTime,
      endTime,
    );

    switch (statisticsType) {
      case StatisticsType.count:
        final context = HealthDataAggregationParameters(
          formattedData: formattedData,
          aggregatedData: aggregatedData,
          startTime: startTime,
          endTime: endTime,
          groupBy: groupBy,
          statisticsType: statisticsType,
        );
        return _buildOverallAverageResponse(context);
      case StatisticsType.average:
        return _buildAggregatedStatisticsResponse(
          aggregatedData,
          statisticsType,
        );
    }
  }

  List<Map<String, dynamic>> _buildOverallAverageResponse(
    HealthDataAggregationParameters aggregationParameters,
  ) {
    double totalValue = 0;
    int totalDataPoints = 0;

    for (final dataPoint in aggregationParameters.aggregatedData) {
      final value = dataPoint['value'] as double;
      final dataPoints = dataPoint['dataPoints'] as int;

      if (dataPoints > 0) {
        totalValue += value;
        totalDataPoints += dataPoints;
      }
    }

    // ignore: lines_longer_than_80_chars
    final overallAverage =
        // ignore: lines_longer_than_80_chars
        totalDataPoints > 0
            ? totalValue / aggregationParameters.aggregatedData.length
            : 0.0;

    return [
      {
        // ignore: lines_longer_than_80_chars
        'type': aggregationParameters.formattedData.isNotEmpty
            ? aggregationParameters.formattedData.first['type']
            : 'UNKNOWN',
        'value': overallAverage,
        // ignore: lines_longer_than_80_chars
        'unit': aggregationParameters.formattedData.isNotEmpty
            ? aggregationParameters.formattedData.first['unit']
            : 'NO_UNIT',
        'dateFrom': aggregationParameters.startTime.toIso8601String(),
        'dateTo': aggregationParameters.endTime.toIso8601String(),
        'sourcePlatform': 'Aggregated',
        'sourceDeviceId': '',
        'sourceId': '',
        'sourceName': 'Overall average for ${aggregationParameters.groupBy}',
        'groupBy': aggregationParameters.groupBy,
        'dataPoints': totalDataPoints,
        'isAverage': true,
        'statisticsType': aggregationParameters.statisticsType.value,
      },
    ];
  }

  List<Map<String, dynamic>> _buildAggregatedStatisticsResponse(
    List<Map<String, dynamic>> aggregatedData,
    StatisticsType statisticsType,
  ) =>
      aggregatedData
          .map(
            (dataPoint) => {
              ...dataPoint,
              'statisticsType': statisticsType.value,
            },
          )
          .toList();

  /// Aggregates health data by the specified time period
  List<Map<String, dynamic>> _aggregateHealthData(
    List<Map<String, dynamic>> data,
    String groupBy,
    DateTime startTime,
    DateTime endTime,
  ) {
    if (data.isEmpty) return [];

    // Generate time segments for the entire range
    final List<DateTime> timeSegments = _generateTimeSegments(
      startTime,
      endTime,
      groupBy,
    );
    final List<Map<String, dynamic>> aggregatedData = [];

    for (int i = 0; i < timeSegments.length - 1; i++) {
      final DateTime segmentStart = timeSegments[i];
      final DateTime segmentEnd = timeSegments[i + 1];

      // Filter data points that fall within this specific segment
      final filteredData = data.where((point) {
        final DateTime pointDate = DateTime.parse(point['dateFrom']);
        return pointDate.isAfter(
              segmentStart.subtract(
                const Duration(
                  milliseconds: 1,
                ),
              ),
            ) &&
            pointDate.isBefore(segmentEnd);
      }).toList();

      final aggregatedValue = _aggregateValues(filteredData);

      aggregatedData.add({
        'type': data.isNotEmpty ? data.first['type'] : 'UNKNOWN',
        'value': aggregatedValue,
        'unit': data.isNotEmpty ? data.first['unit'] : 'NO_UNIT',
        'dateFrom': segmentStart.toIso8601String(),
        'dateTo': segmentEnd.toIso8601String(),
        'sourcePlatform': 'Aggregated',
        'sourceDeviceId': '',
        'sourceId': '',
        'sourceName': 'Grouped by $groupBy',
        'groupBy': groupBy,
        'dataPoints': filteredData.length,
      });
    }

    return aggregatedData;
  }

  /// Generates time segments for the given range and groupBy period
  List<DateTime> _generateTimeSegments(
    DateTime startTime,
    DateTime endTime,
    String groupBy,
  ) {
    final List<DateTime> segments = [];
    DateTime current = _alignToGroupBy(startTime, groupBy);

    while (current.isBefore(endTime)) {
      segments.add(current);
      current = _getNextSegment(current, groupBy);
    }

    // Add the final segment end
    if (segments.isEmpty || segments.last.isBefore(endTime)) {
      segments.add(endTime);
    }

    return segments;
  }

  /// Aligns a datetime to the start of the groupBy period
  DateTime _alignToGroupBy(DateTime dateTime, String groupBy) {
    switch (groupBy.toLowerCase()) {
      case 'hour':
        return DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
        );
      case 'day':
        return DateTime(dateTime.year, dateTime.month, dateTime.day);
      case 'week':
        final int daysToSubtract = dateTime.weekday - 1;
        return DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day - daysToSubtract,
        );
      case 'month':
        return DateTime(dateTime.year, dateTime.month);
      default:
        return dateTime;
    }
  }

  /// Gets the next segment based on the groupBy period
  DateTime _getNextSegment(DateTime current, String groupBy) {
    switch (groupBy.toLowerCase()) {
      case 'hour':
        return current.add(const Duration(hours: 1));
      case 'day':
        return current.add(const Duration(days: 1));
      case 'week':
        return current.add(const Duration(days: 7));
      case 'month':
        return DateTime(current.year, current.month + 1);
      default:
        return current.add(const Duration(days: 1));
    }
  }

  /// Aggregates values from multiple data points
  double _aggregateValues(List<Map<String, dynamic>> dataPoints) {
    if (dataPoints.isEmpty) return 0;

    final String dataType = dataPoints.first['type'];
    double total = 0;

    for (final point in dataPoints) {
      final dynamic value = point['value'];
      if (value is num) {
        total += value.toDouble();
      }
    }

    // For instantaneous data types (heart rate, blood pressure), return average
    if (!_isCumulativeDataType(dataType) && dataPoints.isNotEmpty) {
      return total / dataPoints.length;
    }

    // For cumulative data types (steps, calories, distance), return sum
    return total;
  }

  /// Determines if a data type should be summed or averaged
  bool _isCumulativeDataType(String dataType) {
    const cumulativeTypes = {
      'STEPS',
      'DISTANCE_DELTA',
      'ACTIVE_ENERGY_BURNED',
      'BASAL_ENERGY_BURNED',
      'WORKOUT',
      'WATER',
      'SLEEP_SESSION',
      'SLEEP_ASLEEP',
      'SLEEP_AWAKE',
      'SLEEP_DEEP',
      'SLEEP_LIGHT',
      'SLEEP_REM',
    };

    return cumulativeTypes.contains(dataType.toUpperCase());
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
  ) {
    final response = {
      'success': true,
      'count': healthData.length,
      'healthData': healthData,
      'value_type': args['value_type'],
      'startTime': args['startTime'],
      'endTime': args['endTime'],
    };

    // Include groupBy info if present
    if (args['groupBy'] != null) {
      response['groupBy'] = args['groupBy'];
      response['isAggregated'] = true;
    } else {
      response['isAggregated'] = false;
    }

    // Include statistics type if present
    if (args['statics'] != null) {
      response['statisticsType'] = args['statics'];
    }

    return response;
  }

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
