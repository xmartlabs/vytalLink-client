import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/ui/home/home_cubit.dart';
import 'package:flutter_template/ui/home/widgets/ai_integration_card.dart';
import 'package:flutter_template/ui/home/widgets/animated_credentials_card.dart';
import 'package:flutter_template/ui/home/widgets/animated_server_card.dart';
import 'package:flutter_template/ui/home/widgets/how_it_works_section.dart';
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
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
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
                Icon(
                  FontAwesomeIcons.heartPulse,
                  color: context.theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.app_name,
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: context.theme.colorScheme.surface,
            elevation: 2,
            shadowColor: context.theme.colorScheme.primary
                .withAlpha((0.1 * 255).toInt()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedCredentialCard(
                    connectionWord: state.connectionWord,
                    connectionCode: state.connectionCode,
                  ),
                  AnimatedServerCard(
                    status: state.status,
                    errorMessage: state.errorMessage,
                    pulseAnimation: _pulseAnimation,
                    onStartPressed: () =>
                        context.read<HomeCubit>().checkAndStartServer(),
                  ),
                  const AiIntegrationCard(),
                  const HowItWorksSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
}
