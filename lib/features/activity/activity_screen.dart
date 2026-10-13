import 'package:flutter/material.dart';

import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_pill.dart';
import '../connection/connect_required_state.dart';
import 'activity_controller.dart';
import 'activity_models.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({
    super.key,
    required this.controller,
    required this.isPaired,
  });

  final ActivityController controller;
  final bool isPaired;

  @override
  Widget build(BuildContext context) {
    if (!isPaired) {
      return const ConnectRequiredState(
        title: 'No server connected yet',
        message: 'Activity appears after pairing with a Codex Dev Server.',
      );
    }
    if (controller.loading && controller.items.isEmpty) {
      return const LoadingState(label: 'Loading activity');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 96),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  'Activity',
                  subtitle: 'Recent server and app control-surface events.',
                ),
              ),
              IconButton(
                key: const Key('activity-refresh-button'),
                tooltip: 'Refresh activity',
                onPressed: controller.loading ? null : controller.load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          );
        }
        final item = controller.items[index - 1];
        return AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(label: _label(item.level), tone: _tone(item.level)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(item.detail),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemCount: controller.items.length + 1,
    );
  }

  static String _label(ActivityLevel level) => switch (level) {
    ActivityLevel.info => 'Info',
    ActivityLevel.success => 'OK',
    ActivityLevel.warning => 'Warn',
    ActivityLevel.error => 'Error',
  };

  static StatusTone _tone(ActivityLevel level) => switch (level) {
    ActivityLevel.info => StatusTone.neutral,
    ActivityLevel.success => StatusTone.success,
    ActivityLevel.warning => StatusTone.warning,
    ActivityLevel.error => StatusTone.error,
  };
}
