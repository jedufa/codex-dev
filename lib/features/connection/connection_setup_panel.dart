import 'package:flutter/material.dart';
import 'connection_controller.dart';
import 'connection_models.dart';

class ConnectionSetupPanel extends StatelessWidget {
  const ConnectionSetupPanel({
    super.key,
    required this.controller,
    required this.onPaired,
    this.compact = false,
  });
  final ConnectionController controller;
  final Future<void> Function() onPaired;
  final bool compact;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Simulation disconnected',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Reconnect the in-memory demo. No server, account or pairing code is needed.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('demo-reconnect'),
            onPressed: () async {
              await controller.pair(
                const PairServerInput(
                  host: 'demo.invalid',
                  port: 443,
                  pairingCode: 'inert-demo',
                ),
              );
              await onPaired();
            },
            child: const Text('Reconnect simulation'),
          ),
        ],
      ),
    ),
  );
}
