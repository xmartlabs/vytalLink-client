import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/common/config.dart';
import 'package:flutter_template/core/source/mcp_server.dart';
import 'package:flutter_template/ui/section/error_handler/global_event_handler_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GlobalEventHandler _globalEventHandler;
  late final HealthMcpServerService healthServer;

  HomeCubit(this._globalEventHandler) : super(const HomeState()) {
    WakelockPlus.enable();
    _initialize();
  }

  Future<void> _initialize() async {
    final ip = await NetworkInfo().getWifiIP();

    final config = HealthMcpServerConfig(
      serverName: Config.mcpServerName,
      serverVersion: Config.mcpServerVersion,
      host: ip ?? Config.mcpHostFallback,
      port: Config.mcpPort,
      endpoint: Config.mcpEndpoint,
    );

    healthServer = HealthMcpServerService(
      config: config,
    );
    await healthServer.initialize();
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    return super.close();
  }

  Future<void> startMCPServer() async {
    try {
      emit(state.copyWith(status: McpServerStatus.starting));

      await healthServer.start();

      emit(
        state.copyWith(
          status: McpServerStatus.running,
          ipAddress: healthServer.config.host,
          endpoint: healthServer.config.endpoint,
        ),
      );
    } catch (error, stackTrace) {
      _globalEventHandler.handleError(error, stackTrace);
      emit(state.copyWith(status: McpServerStatus.idle));
    }
  }

  Future<void> stopMCPServer() async {
    try {
      emit(state.copyWith(status: McpServerStatus.stopping));

      await healthServer.stop();

      emit(
        state.copyWith(
          status: McpServerStatus.idle,
          ipAddress: "",
          endpoint: "",
        ),
      );
    } catch (error, stackTrace) {
      _globalEventHandler.handleError(error, stackTrace);
      emit(
        state.copyWith(
          status: McpServerStatus.idle,
          ipAddress: "",
          endpoint: "",
        ),
      );
    }
  }
}
