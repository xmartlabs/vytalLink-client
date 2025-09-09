import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/common/config.dart';
import 'package:flutter_template/core/source/mcp_server.dart';
import 'package:flutter_template/ui/resources.dart';
import 'package:flutter_template/ui/section/error_handler/global_event_handler_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health/health.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'home_cubit.freezed.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GlobalEventHandler _globalEventHandler;
  late final HealthMcpServerService healthServer;
  Timer? _connectionCheckTimer;

  HomeCubit(this._globalEventHandler) : super(const HomeState()) {
    WakelockPlus.enable();
    _initialize();
  }

  List<HealthDataType> get _requiredHealthDataTypes => [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.SLEEP_SESSION,
        HealthDataType.WORKOUT,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.TOTAL_CALORIES_BURNED,
      ];

  List<HealthDataType> get _platformSpecificHealthDataTypes =>
      (Platform.isAndroid ? dataTypeKeysAndroid : dataTypeKeysIOS)
          .where((type) => _requiredHealthDataTypes.contains(type))
          .toList();

  Future<void> _initialize() async {
    final ip = await NetworkInfo().getWifiIP();

    final config = HealthMcpServerConfig(
      serverName: Config.mcpServerName,
      serverVersion: Config.mcpServerVersion,
      host: ip ?? Config.mcpHostFallback,
      port: Config.mcpPort,
      endpoint: Config.mcpEndpoint,
    );

    healthServer = HealthMcpServerService(config: config)
      ..setConnectionCodeCallback(_onConnectionCodeReceived)
      ..setConnectionErrorCallback(_onConnectionError)
      ..setConnectionLostCallback(_onConnectionLost);
    await healthServer.initialize();
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    _connectionCheckTimer?.cancel();
    return super.close();
  }

  void _startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _checkConnectionStatus(),
    );
  }

  void _stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
  }

  void _checkConnectionStatus() {
    if (state.status == McpServerStatus.running && !healthServer.isConnected) {
      emit(
        state.copyWith(
          status: McpServerStatus.error,
          ipAddress: "",
          endpoint: "",
          connectionCode: "",
          connectionWord: "",
          errorMessage: Resources.localizations.connection_lost_unexpectedly,
        ),
      );
    }
  }

  void _onConnectionCodeReceived(String code, String word, String message) {
    emit(
      state.copyWith(
        connectionCode: code,
        connectionWord: word,
      ),
    );
  }

  void _onConnectionError(String error) {
    _stopConnectionMonitoring();
    _globalEventHandler.handleError(
      CategorizedError(
        ErrorCategory.connection,
        Resources.localizations.connection_error_title,
      ),
      null,
      () => startMCPServer(),
    );
    emit(
      state.copyWith(
        status: McpServerStatus.error,
        ipAddress: "",
        endpoint: "",
        connectionCode: "",
        connectionWord: "",
        errorMessage: "",
      ),
    );
  }

  void _onConnectionLost() {
    _stopConnectionMonitoring();
    emit(
      state.copyWith(
        status: McpServerStatus.error,
        ipAddress: "",
        endpoint: "",
        connectionCode: "",
        connectionWord: "",
        errorMessage: "",
      ),
    );
  }

  Future<bool> hasAllHealthPermissions() async {
    try {
      await healthServer.initialize();

      final healthDataTypes = _platformSpecificHealthDataTypes;

      final permissions = List.generate(
        healthDataTypes.length,
        (_) => HealthDataAccess.READ,
      );

      final hasPermissions = await healthServer.healthClient.hasPermissions(
        healthDataTypes,
        permissions: permissions,
      );

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

      final healthDataTypes = _platformSpecificHealthDataTypes;

      final permissions = List.generate(
        healthDataTypes.length,
        (_) => HealthDataAccess.READ,
      );

      final permissionsGranted =
          await healthServer.healthClient.requestAuthorization(
        healthDataTypes,
        permissions: permissions,
      );

      if (!permissionsGranted) {
        return false;
      }

      try {
        await healthServer.healthClient.requestHealthDataHistoryAuthorization();

        final hasHistoryPermissions =
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

  Future<void> startMCPServer() async {
    try {
      _globalEventHandler.clearError();
      emit(
        state.copyWith(
          status: McpServerStatus.starting,
          errorMessage: "",
        ),
      );

      final hasPermissions = await hasAllHealthPermissions();
      if (!hasPermissions) {
        emit(
          state.copyWith(
            status: McpServerStatus.idle,
            errorMessage: "",
          ),
        );
        return;
      }

      await healthServer.connectToBackend();

      if (!healthServer.isConnected) {
        throw CategorizedError(
          ErrorCategory.connection,
          Resources.localizations.connection_could_not_establish,
        );
      }

      emit(
        state.copyWith(
          status: McpServerStatus.running,
          ipAddress: healthServer.config.host,
          endpoint: healthServer.config.endpoint,
          errorMessage: "",
        ),
      );

      _startConnectionMonitoring();
    } catch (error) {
      emit(
        state.copyWith(
          status: McpServerStatus.error,
          errorMessage: "",
        ),
      );
    }
  }

  Future<void> checkAndStartServer() async {
    final hasPermissions = await hasAllHealthPermissions();
    if (hasPermissions) {
      await startMCPServerWithPermissions();
    } else {
      final permissionsGranted = await requestHealthPermissions();
      if (permissionsGranted) {
        await startMCPServerWithPermissions();
      }
    }
  }

  Future<void> startMCPServerWithPermissions() async {
    try {
      _globalEventHandler.clearError();
      emit(
        state.copyWith(
          status: McpServerStatus.starting,
          errorMessage: "",
        ),
      );

      await healthServer.connectToBackend();

      if (!healthServer.isConnected) {
        throw CategorizedError(
          ErrorCategory.connection,
          Resources.localizations.connection_could_not_establish,
        );
      }

      emit(
        state.copyWith(
          status: McpServerStatus.running,
          ipAddress: healthServer.config.host,
          endpoint: healthServer.config.endpoint,
          errorMessage: "",
        ),
      );

      _startConnectionMonitoring();
    } catch (error) {
      emit(
        state.copyWith(
          status: McpServerStatus.error,
          errorMessage: "",
        ),
      );
    }
  }

  Future<void> stopMCPServer() async {
    try {
      emit(state.copyWith(status: McpServerStatus.stopping));

      _stopConnectionMonitoring();
      await healthServer.stop();

      emit(
        state.copyWith(
          status: McpServerStatus.idle,
          ipAddress: "",
          endpoint: "",
          connectionCode: "",
          connectionWord: "",
          errorMessage: "",
        ),
      );
    } catch (error, stackTrace) {
      _globalEventHandler.handleError(error, stackTrace);
      emit(
        state.copyWith(
          status: McpServerStatus.idle,
          ipAddress: "",
          endpoint: "",
          connectionCode: "",
          connectionWord: "",
          errorMessage: "",
        ),
      );
    }
  }
}
