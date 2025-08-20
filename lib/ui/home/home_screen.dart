import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/ui/extensions/context_extensions.dart';
import 'package:flutter_template/ui/home/home_cubit.dart';
import 'package:flutter_template/ui/section/error_handler/global_event_handler_cubit.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => HomeCubit(context.read<GlobalEventHandlerCubit>()),
        child: const _HomeContentScreen(),
      );
}

class _HomeContentScreen extends StatelessWidget {
  const _HomeContentScreen();

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
              context.localizations.home_title,
              style: TextStyle(
                color: context.theme.customColors.textColor?.getShade(100),
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getServerIcon(state),
                    size: 120,
                    color: _getServerIconColor(context, state),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: Text(
                      _getServerDescriptionText(context, state),
                      style: context.theme.textStyles.bodyLarge?.copyWith(
                        color: context.theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 60,
                    child: Column(
                      children: [
                        if (state.ipAddress.isNotEmpty)
                          Text(
                            context.localizations
                                .home_server_ip_label(state.ipAddress),
                            style:
                                context.theme.textStyles.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (state.endpoint.isNotEmpty)
                          Text(
                            context.localizations
                                .home_endpoint_label(state.endpoint),
                            style:
                                context.theme.textStyles.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(context, state),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildActionButton(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return _startButton(context);
      case McpServerStatus.starting:
        return _loadingButton(
          context,
          context.localizations.home_button_starting,
        );
      case McpServerStatus.running:
        return _stopButton(context);
      case McpServerStatus.stopping:
        return _loadingButton(
          context,
          context.localizations.home_button_stopping,
        );
    }
  }

  Widget _startButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.read<HomeCubit>().startMCPServer(),
          icon: const Icon(Icons.play_arrow),
          label: Text(context.localizations.home_button_start_server),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: context.theme.colorScheme.primary,
            foregroundColor:
                context.theme.customColors.textColor?.getShade(100),
          ),
        ),
      );

  Widget _stopButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.read<HomeCubit>().stopMCPServer(),
          icon: const Icon(Icons.stop),
          label: Text(context.localizations.home_button_stop_server),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: context.theme.customColors.danger,
            foregroundColor:
                context.theme.customColors.textColor?.getShade(100),
          ),
        ),
      );

  Widget _loadingButton(BuildContext context, String label) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );

  IconData _getServerIcon(HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return Icons.cloud_off;
      case McpServerStatus.starting:
        return Icons.cloud_sync;
      case McpServerStatus.running:
        return Icons.cloud_done;
      case McpServerStatus.stopping:
        return Icons.cloud_sync;
    }
  }

  Color _getServerIconColor(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return context.theme.colorScheme.onSurface.withValues(alpha: 0.5);
      case McpServerStatus.starting:
        return context.theme.colorScheme.primary;
      case McpServerStatus.running:
        return Colors.green;
      case McpServerStatus.stopping:
        return context.theme.colorScheme.primary;
    }
  }

  String _getServerStatusText(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return context.localizations.home_status_offline;
      case McpServerStatus.starting:
        return context.localizations.home_status_starting;
      case McpServerStatus.running:
        return context.localizations.home_status_running;
      case McpServerStatus.stopping:
        return context.localizations.home_status_stopping;
    }
  }

  String _getServerDescriptionText(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return context.localizations.home_description_offline;
      case McpServerStatus.starting:
        return context.localizations.home_description_starting;
      case McpServerStatus.running:
        return context.localizations.home_description_running;
      case McpServerStatus.stopping:
        return context.localizations.home_description_stopping;
    }
  }
}
