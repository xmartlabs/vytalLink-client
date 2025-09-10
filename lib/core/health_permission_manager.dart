import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter_template/core/source/mcp_server.dart';
import 'package:flutter_template/model/vytal_health_data_category.dart';
import 'package:health/health.dart';

class HealthPermissionManager {
  final HealthMcpServerService healthServer;
  late List<HealthDataType> _requiredHealthDataTypes;

  HealthPermissionManager(this.healthServer) {
    _requiredHealthDataTypes = VytalHealthDataCategory.values
        .flatMap((category) => category.platformHealthDataTypes)
        .distinct()
        .toList();
  }

  Future<bool> hasAllHealthPermissions() async {
    try {
      await healthServer.initialize();
      final hasPermissions = await healthServer.healthClient
          .hasPermissions(_requiredHealthDataTypes);
      final hasHistoryPermissions =
          await healthServer.healthClient.isHealthDataHistoryAuthorized();
      return (hasPermissions ?? false) && hasHistoryPermissions;
    } catch (error) {
      return false;
    }
  }

  Future<bool> requestHealthPermissions() async {
    try {
      await healthServer.initialize();
      final permissions = List.generate(
        _requiredHealthDataTypes.length,
        (_) => HealthDataAccess.READ,
      );
      final permissionsGranted =
          await healthServer.healthClient.requestAuthorization(
        _requiredHealthDataTypes,
        permissions: permissions,
      );
      if (!permissionsGranted) {
        return false;
      }
      try {
        await healthServer.healthClient.requestHealthDataHistoryAuthorization();
        final hasHistoryPermissions = Platform.isIOS ||
            await healthServer.healthClient.isHealthDataHistoryAuthorized();
        if (!hasHistoryPermissions) {
          return false;
        }
      } catch (historyError) {
        return false;
      }
      return true;
    } catch (error) {
      return false;
    }
  }
}
