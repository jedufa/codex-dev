import 'package:flutter/material.dart';

import '../../../shared/widgets/status_pill.dart';

class ChatStatusBanner extends StatelessWidget {
  const ChatStatusBanner({
    super.key,
    required this.message,
    required this.tone,
  });

  final String message;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        children: [
          StatusPill(
            label: tone == StatusTone.error ? 'Error' : 'Running',
            tone: tone,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
