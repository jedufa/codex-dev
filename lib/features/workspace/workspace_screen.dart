import 'package:flutter/material.dart';

import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_pill.dart';
import '../connection/connect_required_state.dart';
import 'workspace_controller.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    super.key,
    required this.controller,
    required this.isPaired,
  });

  final WorkspaceController controller;
  final bool isPaired;

  @override
  Widget build(BuildContext context) {
    if (!isPaired) {
      return const ConnectRequiredState(
        title: 'Connect a server',
        message: 'Connect a server to see projects.',
      );
    }
    if (controller.loading && controller.status == null) {
      return const LoadingState(label: 'Loading workspace');
    }
    if (controller.errorMessage != null) {
      return ErrorState(message: controller.errorMessage!);
    }
    final status = controller.status;
    if (status == null) {
      return const ErrorState(message: 'Workspace unavailable');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 96),
      children: [
        const SectionHeader(
          'Workspace',
          subtitle: 'Current project context for future Codex turns.',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      status.projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const StatusPill(label: 'Mock', tone: StatusTone.neutral),
                ],
              ),
              const SizedBox(height: 8),
              Text(status.projectRoot),
              const SizedBox(height: 8),
              Text(status.summary),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project server',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(status.serverUrl),
              const SizedBox(height: 10),
              StatusPill(
                label: '${status.filesChanged} files changed',
                tone: StatusTone.neutral,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
