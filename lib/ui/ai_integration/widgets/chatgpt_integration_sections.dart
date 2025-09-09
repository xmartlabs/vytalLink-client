import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/common/config.dart';
import 'package:flutter_template/ui/ai_integration/widgets/section_card.dart';
import 'package:flutter_template/ui/ai_integration/widgets/setup_step.dart';
import 'package:flutter_template/ui/extensions/context_extensions.dart';
import 'package:flutter_template/ui/helpers/url_launcher_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WhatIsChatGptSection extends StatelessWidget {
  const WhatIsChatGptSection({super.key});

  @override
  Widget build(BuildContext context) => SectionCard(
        icon: FontAwesomeIcons.circleInfo,
        title: context.localizations.chatgpt_what_is_title,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localizations.chatgpt_what_is_description,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class ExamplesSection extends StatelessWidget {
  const ExamplesSection({super.key});

  @override
  Widget build(BuildContext context) => SectionCard(
        icon: FontAwesomeIcons.lightbulb,
        title: context.localizations.chatgpt_examples_title,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localizations.chatgpt_examples_description,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

class HowToSetupSection extends StatelessWidget {
  const HowToSetupSection({super.key});

  @override
  Widget build(BuildContext context) => SectionCard(
        icon: FontAwesomeIcons.gear,
        title: context.localizations.chatgpt_setup_title,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SetupStep(
              number: '1',
              title: context.localizations.chatgpt_step_1_title,
              description: context.localizations.chatgpt_step_1_description,
            ),
            const SizedBox(height: 24),
            SetupStep(
              number: '2',
              title: context.localizations.chatgpt_step_2_title,
              description: context.localizations.chatgpt_step_2_description,
            ),
            const SizedBox(height: 24),
            SetupStep(
              number: '3',
              title: context.localizations.chatgpt_step_3_title,
              description: context.localizations.chatgpt_step_3_description,
            ),
            const SizedBox(height: 24),
            SetupStep(
              number: '4',
              title: context.localizations.chatgpt_step_4_title,
              description: context.localizations.chatgpt_step_4_description,
            ),
          ],
        ),
      );
}

class ChatGptIntegrationHeroSection extends StatelessWidget {
  const ChatGptIntegrationHeroSection({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.theme.colorScheme.secondary
                  .withAlpha((0.05 * 255).toInt()),
              context.theme.colorScheme.secondary
                  .withAlpha((0.15 * 255).toInt()),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.theme.colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.theme.colorScheme.secondary,
                    context.theme.colorScheme.secondary
                        .withAlpha((0.8 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  FontAwesomeIcons.comments,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.localizations.chatgpt_integration_hero_title,
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.localizations.chatgpt_integration_hero_subtitle,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class ChatGptUseButtonSection extends StatelessWidget {
  const ChatGptUseButtonSection({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => UrlLauncherHelper.launch(Config.gptIntegrationUrl),
          icon: const Icon(FontAwesomeIcons.comments, size: 20),
          label: Text(
            context.localizations.chatgpt_start_button,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
