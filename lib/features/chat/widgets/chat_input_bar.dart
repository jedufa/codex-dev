import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
    required this.onCancel,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isSending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
        decoration: BoxDecoration(
          color: context.appColors.floatingSurface,
          border: Border(
            top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('chat-composer-field'),
                controller: controller,
                enabled: enabled,
                onChanged: onChanged,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Message Codex Dev',
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 40,
              child: IconButton.filled(
                key: const Key('chat-send-button'),
                onPressed: enabled && controller.text.trim().isNotEmpty
                    ? onSend
                    : null,
                tooltip: isSending ? 'Queue prompt' : 'Send',
                icon: const Icon(Icons.send_rounded, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
            if (isSending) ...[
              const SizedBox(width: 6),
              SizedBox.square(
                dimension: 40,
                child: IconButton.filledTonal(
                  key: const Key('chat-stop-button'),
                  onPressed: onCancel,
                  tooltip: 'Stop Codex turn',
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
