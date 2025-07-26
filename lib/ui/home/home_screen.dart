import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            title: const Text('MCP Server Control'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getServerIcon(state),
                    size: 120,
                    color: _getServerIconColor(context, state),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _getServerStatusText(state),
                    style: context.theme.textStyles.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getServerDescriptionText(state),
                    style: context.theme.textStyles.bodyLarge?.copyWith(
                      color:
                          context.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.read<HomeCubit>().startMCPServer(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start MCP Server'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: context.theme.colorScheme.onPrimary,
            ),
          ),
        );
      case McpServerStatus.starting:
        return SizedBox(
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
            label: const Text('Starting...'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      case McpServerStatus.running:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.read<HomeCubit>().stopMCPServer(),
            icon: const Icon(Icons.stop),
            label: const Text('Stop MCP Server'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.theme.colorScheme.error,
              foregroundColor: context.theme.colorScheme.onError,
            ),
          ),
        );
      case McpServerStatus.stopping:
        return SizedBox(
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
            label: const Text('Stopping...'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
    }
  }

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
        return context.theme.colorScheme.onSurface.withOpacity(0.5);
      case McpServerStatus.starting:
        return context.theme.colorScheme.primary;
      case McpServerStatus.running:
        return Colors.green;
      case McpServerStatus.stopping:
        return context.theme.colorScheme.primary;
    }
  }

  String _getServerStatusText(HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return 'MCP Server Offline';
      case McpServerStatus.starting:
        return 'Starting Server...';
      case McpServerStatus.running:
        return 'MCP Server Running';
      case McpServerStatus.stopping:
        return 'Stopping Server...';
    }
  }

  String _getServerDescriptionText(HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return 'Ready to start the Model Context Protocol server on this device';
      case McpServerStatus.starting:
        return 'Initializing MCP server and binding to port...';
      case McpServerStatus.running:
        return 'Server is active and ready to accept connections';
      case McpServerStatus.stopping:
        return 'Shutting down server and closing connections...';
    }
  }
}
