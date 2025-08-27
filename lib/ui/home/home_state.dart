part of 'home_cubit.dart';

enum McpServerStatus { idle, starting, running, stopping }

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(McpServerStatus.idle) McpServerStatus status,
    @Default("") String ipAddress,
    @Default("") String endpoint,
  }) = _HomeState;
}
