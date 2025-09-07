import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/extensions/color_extensions.dart';
import 'package:design_system/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/ui/extensions/context_extensions.dart';
import 'package:flutter_template/ui/home/home_cubit.dart';
import 'package:flutter_template/ui/section/error_handler/global_event_handler_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => HomeCubit(context.read<GlobalEventHandlerCubit>()),
        child: const _HomeContentScreen(),
      );
}

class _HomeContentScreen extends StatefulWidget {
  const _HomeContentScreen();

  @override
  State<_HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<_HomeContentScreen> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.theme.colorScheme.surface,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Updated the heart icon to use Font Awesome's heartbeat icon
                Icon(
                  FontAwesomeIcons.heartbeat,
                  color: context.theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'vytalLink',
                  style: TextStyle(
                    color: context.theme.customColors.textColor!.getShade(400),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: context.theme.colorScheme.surface,
            elevation: 2,
            shadowColor: context.theme.colorScheme.primary.withOpacity(0.1),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: state.connectionCode.isNotEmpty && state.connectionWord.isNotEmpty
                        ? Column(
                            children: [
                              _buildCredentialsCard(context, state),
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  VytalLinkCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getServerIconColor(context, state).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: state.status == McpServerStatus.running ? [
                                      BoxShadow(
                                        color: _getServerIconColor(context, state).withOpacity(0.3),
                                        offset: const Offset(0, 0),
                                        blurRadius: 10 * _pulseAnimation.value,
                                        spreadRadius: 1,
                                      ),
                                    ] : null,
                                  ),
                                  child: Transform.scale(
                                    scale: state.status == McpServerStatus.running ? _pulseAnimation.value : 1.0,
                                    child: AnimatedRotation(
                                      duration: const Duration(seconds: 2),
                                      turns: state.status == McpServerStatus.starting || 
                                             state.status == McpServerStatus.stopping ? 1 : 0,
                                      child: Icon(
                                        _getServerIcon(state),
                                        size: 32,
                                        color: _getServerIconColor(context, state),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getServerStatusTitle(context, state),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: context.theme.customColors.textColor!.getShade(400),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getServerDescriptionText(context, state),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.theme.customColors.textColor!.getShade(300),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (state.status == McpServerStatus.running)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.theme.customColors.success!.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.theme.customColors.success!.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: context.theme.customColors.success,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ONLINE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.theme.customColors.success,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(context, state),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
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
      case McpServerStatus.error:
        return _errorButton(context, state);
    }
  }

  Widget _buildCredentialsCard(BuildContext context, HomeState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: (value).clamp(0.0, 1.0),
              child: VytalLinkCard(
                padding: const EdgeInsets.all(24),
                backgroundColor: context.theme.colorScheme.primary.withOpacity(0.08),
                border: Border.all(
                  color: context.theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: context.theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.connection_section_title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: 20,
                            color: context.theme.colorScheme.primary.withOpacity(0.7),
                          ),
                          onPressed: () => _showCredentialsInfo(context),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildUnifiedCredentials(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnifiedCredentials(BuildContext context, HomeState state) {
    final credentialsText = 'Word: ${state.connectionWord} • PIN: ${state.connectionCode}';
    
    return VytalLinkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.connection_credentials_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.theme.customColors.textColor!.getShade(400),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: credentialsText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.credentials_copied_to_clipboard),
                      backgroundColor: context.theme.customColors.success,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.credentials_word_label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: context.theme.customColors.textColor!.getShade(300),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.connectionWord,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.theme.colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.credentials_pin_label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: context.theme.customColors.textColor!.getShade(300),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.connectionCode,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.theme.colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.theme.customColors.warning!.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.theme.customColors.warning!.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.theme.customColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.credentials_keep_app_open,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.theme.customColors.textColor!.getShade(300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getServerStatusTitle(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return 'MCP Server Ready';
      case McpServerStatus.starting:
        return 'Starting Server...';
      case McpServerStatus.running:
        return 'Server Online';
      case McpServerStatus.stopping:
        return 'Stopping Server...';
      case McpServerStatus.error:
        return 'Server Error';
    }
  }

  Widget _startButton(BuildContext context) => VytalLinkButton(
        onPressed: () => context.read<HomeCubit>().startMCPServer(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              context.localizations.home_button_start_server,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
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
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 4,
            shadowColor: context.theme.customColors.danger!.withOpacity(0.3),
          ),
        ),
      );

  Widget _loadingButton(BuildContext context, String label) => SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            color: context.theme.customColors.textColor!.getShade(300),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _errorButton(BuildContext context, HomeState state) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.customColors.danger!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.theme.customColors.danger!.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: context.theme.customColors.danger,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.connection_error_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.theme.customColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage.isNotEmpty 
                    ? state.errorMessage 
                    : AppLocalizations.of(context)!.connection_could_not_connect_default,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.theme.customColors.textColor!.getShade(300),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<HomeCubit>().startMCPServer(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.connection_retry_button),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
                shadowColor: context.theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
        ],
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
      case McpServerStatus.error:
        return Icons.cloud_off;
    }
  }

  Color _getServerIconColor(BuildContext context, HomeState state) {
    switch (state.status) {
      case McpServerStatus.idle:
        return context.theme.customColors.textColor!.getShade(300);
      case McpServerStatus.starting:
        return context.theme.colorScheme.primary;
      case McpServerStatus.running:
        return context.theme.customColors.success!;
      case McpServerStatus.stopping:
        return context.theme.colorScheme.primary;
      case McpServerStatus.error:
        return context.theme.customColors.danger!;
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
      case McpServerStatus.error:
        return AppLocalizations.of(context)!.home_description_error;
    }
  }

  void _showCredentialsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.connection_credentials_info_title),
        content: Text(AppLocalizations.of(context)!.connection_credentials_info_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.error_button_ok),
          ),
        ],
      ),
    );
  }
}
