import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/source/mcp_server.dart';
import 'package:flutter_template/ui/section/error_handler/global_event_handler_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GlobalEventHandler _globalEventHandler;

  HomeCubit(this._globalEventHandler) : super(const HomeState()) {
    WakelockPlus.enable();
    // _initialize();
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    return super.close();
  }

  Future<void> startMCPServer() async {
    try {
      emit(state.copyWith(status: McpServerStatus.starting));

      final server = await McpServerSource.myserver();

      emit(state.copyWith(status: McpServerStatus.running));
    } catch (error, stackTrace) {
      _globalEventHandler.handleError(error, stackTrace, startMCPServer);
      emit(state.copyWith(status: McpServerStatus.idle));
    }
  }

  Future<void> stopMCPServer() async {
    try {
      emit(state.copyWith(status: McpServerStatus.stopping));

      await McpServerSource.stop();

      emit(state.copyWith(status: McpServerStatus.idle));
    } catch (error, stackTrace) {
      _globalEventHandler.handleError(error, stackTrace, stopMCPServer);
      emit(state.copyWith(status: McpServerStatus.idle));
    }
  }
}
