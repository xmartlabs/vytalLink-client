import 'dart:io';

import 'package:flutter_template/core/source/mcp_schema.dart';
import 'package:health/health.dart';
import 'package:mcp_server/mcp_server.dart';
import 'package:permission_handler/permission_handler.dart';

class McpServerSource {
  static late Server mcpServer;

  McpServerSource({required String name, required String version}) {
    // mcpServer = Server(
    //   name: name,
    //   version: version,
    //   capabilities: ServerCapabilities.simple(
    //     tools: true,
    //     resources: true,
    //     prompts: true,
    //   ),
    // );
  }

  static Future<void> stop() async => mcpServer.disconnect();

  static Future foo() async {
    final List<HealthDataType> healthTypes = [HealthDataType.STEPS];

    // Obtener instancia de Health
    final Health health = Health();
    await health.configure();
    await health.getHealthConnectSdkStatus();

    await Permission.activityRecognition.request();
    await Permission.location.request();

    final bool hasPermissions = await health.hasPermissions(
          healthTypes,
          // permissions: [HealthDataAccess.READ],
        ) ??
        false;
    if (!hasPermissions) {
      final bool permissionsGranted =
          await health.requestAuthorization(healthTypes);
      if (!permissionsGranted) {
        throw Exception('Health permissions not granted');
      }
    }
  }

  static Future<Server> myserver() async {
    foo();

    final server = await McpServer.createAndStart(
      config: McpServer.simpleConfig(
        name: "health-data-server",
        version: "1.0.0",
      ),
      transportConfig: const TransportConfig.streamableHttp(
        host: '192.168.0.232',
        port: 10000,
        endpoint: '/mcp',
        isJsonResponseEnabled: true, // JSON response mode
      ),
    ).then((server) => server.successOrNull!);

    server.addTool(
      name: "get_health_data",
      description:
          'Retrieve health data from Apple HealthKit or Google Health Connect for specified data types and time range',
      inputSchema: inputSchema,
      handler: (args) async {
        try {
          print('Received args: $args');
          // Extraer parámetros
          final String valueTypeStr = args['value_type'];
          final String startTimeString = args['startTime'];
          final String endTimeString = args['endTime'];
          final HealthDataType valueType = HealthDataType.values.firstWhere(
            (type) => type.name == valueTypeStr,
            orElse: () =>
                throw Exception('Invalid health data type: $valueTypeStr'),
          );

          // Convertir strings a DateTime
          final DateTime startTime = DateTime.parse(startTimeString);
          final DateTime endTime = DateTime.parse(endTimeString);

          // Validar que la fecha de inicio sea anterior a la de fin
          if (startTime.isAfter(endTime)) {
            throw Exception('Start time must be before end time');
          }

          final List<HealthDataType> healthTypes = [valueType];

          // Obtener instancia de Health
          final Health health = Health();

          // Configure health plugin
          await health.configure();

          // Check if Health Connect is available on Android
          if (Platform.isAndroid) {
            print('Checking Health Connect availability...');
            final sdkStatus = await health.getHealthConnectSdkStatus();
            print('Health Connect SDK Status: $sdkStatus');

            final isAvailable = await health.isHealthConnectAvailable();
            print('Health Connect available: $isAvailable');

            if (!isAvailable) {
              throw Exception(
                'Google Health Connect is not available on this device. Please install it from the Play Store.',
              );
            }
          }

          print(
            'Checking permissions for: ${healthTypes.map((t) => t.name).join(', ')}',
          );
          final bool hasPermissions = await health.hasPermissions(
                healthTypes,
                permissions: [HealthDataAccess.READ],
              ) ??
              false;
          print('Has permissions: $hasPermissions');

          if (!hasPermissions) {
            print('Requesting authorization...');
            final bool permissionsGranted = await health.requestAuthorization(
              healthTypes,
              permissions: [HealthDataAccess.READ],
            );
            print('Permissions granted: $permissionsGranted');

            if (!permissionsGranted) {
              throw Exception(
                'Health permissions not granted. Please open Health Connect app and grant permissions manually.',
              );
            }
          }

          final isHealthDataHistoryAuthorized =
              await health.isHealthDataHistoryAuthorized();
          print(
            'Health Data History Authorized: $isHealthDataHistoryAuthorized',
          );
          if (!isHealthDataHistoryAuthorized) {
            await health.requestHealthDataHistoryAuthorization();
          }
          final List<HealthDataPoint> res = [];
          // Obtener los datos de salud
          if (healthTypes[0] == HealthDataType.STEPS) {
            final steps =
                await health.getTotalStepsInInterval(startTime, endTime);
            print('Total steps: $steps');
            res.add(
              HealthDataPoint(
                type: HealthDataType.STEPS,
                value: NumericHealthValue(
                  numericValue: steps ?? 0,
                ),
                dateFrom: startTime,
                dateTo: endTime,
                uuid: '',
                unit: HealthDataUnit.COUNT,
                sourcePlatform: HealthPlatformType.googleHealthConnect,
                sourceDeviceId: '',
                sourceId: '',
                sourceName: '',
              ),
            );
          } else {
            res.addAll(
              await health.getHealthDataFromTypes(
                types: healthTypes,
                startTime: startTime,
                endTime: endTime,
              ),
            );
          }

          // Formatear los datos para la respuesta
          final List<Map<String, dynamic>> formattedData = res
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
                }, // 'type': dataPoint.type.name,
              )
              .toList();

          return CallToolResult(
            content: [
              TextContent(
                text: '''Health Data Retrieved Successfully

Total data points: ${formattedData.length}
Time range: ${startTime.toIso8601String()} to ${endTime.toIso8601String()}
Types requested: ${healthTypes.map((type) => type.name).join(', ')}

Data:
${formatDataForDisplay(formattedData)}''',
              ),
            ],
          );
        } catch (e) {
          return CallToolResult(
            content: [
              TextContent(
                text: 'Error retrieving health data: ${e.toString()}',
              ),
            ],
            isError: true,
          );
        }
      },
    );
//     // final ipLocal = await IpAddress().getIp();
//     // print('Local IP Address: $ipLocal');

    return server;
  }
}

// Función auxiliar para formatear valores de salud
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
  // Para otros tipos, convertir a string
  return value.toString();
}

// Función auxiliar para formatear datos para mostrar
String formatDataForDisplay(List<Map<String, dynamic>> data) {
  if (data.isEmpty) {
    return 'No data found for the specified criteria';
  }

  // Agrupar por tipo para mejor legibilidad
  final Map<String, List<Map<String, dynamic>>> groupedData = {};
  for (final point in data) {
    final String type = point['type'];
    groupedData.putIfAbsent(type, () => []).add(point);
  }

  final StringBuffer buffer = StringBuffer();

  groupedData.forEach((type, points) {
    buffer.writeln('\n$type (${points.length} data points):');

    // Mostrar solo los primeros 5 puntos para evitar respuestas muy largas
    final int displayCount = points.length > 5 ? 5 : points.length;

    for (int i = 0; i < displayCount; i++) {
      final point = points[i];
      buffer.writeln('  - Value: ${point['value']} ${point['unit']}');
      buffer.writeln('    Date: ${point['dateFrom']}');
      buffer.writeln('    Source: ${point['sourceName']}');
    }

    if (points.length > 5) {
      buffer.writeln('  ... and ${points.length - 5} more data points');
    }
  });

  return buffer.toString();
}
  

  // // Example method to start the server
  // void initializeTools() {
  //   //define server tools
  //   mcpServer.tool(
  //     'exampleTool',
  //     description: 'An example tool for demonstration',
  //     callback: ({args, extra}){
  //       // Tool logic goes here
  //       print('Tool called with args: $args and extra: $extra');
  //       return CallToResult();
  //     },
  //   )
  // }

  // // Example method to stop the server
  // void stop() {
  //   // Stop server logic goes here
  // }

