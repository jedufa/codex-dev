import 'package:flutter/material.dart';
import '../connection/connection_controller.dart';
import '../connection/connection_setup_panel.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.connectionController,
    required this.onPaired,
  });
  final SettingsController controller;
  final ConnectionController connectionController;
  final Future<void> Function() onPaired;
  @override
  Widget build(BuildContext context) {
    if (!connectionController.isPaired) {
      return ConnectionSetupPanel(
        controller: connectionController,
        onPaired: onPaired,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'A place to explore the interface',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Everything is simulated in this process: replies, progress, project names and connection status. No commands run and no files are read or changed.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Chat and drafts last only for this app session. Reloading starts over. Speech, attachments, live pairing and account settings are excluded.',
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          key: const Key('demo-disconnect'),
          onPressed: connectionController.disconnectLocal,
          child: const Text('Simulate disconnect'),
        ),
      ],
    );
  }
}
