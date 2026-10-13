import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.streamingProgress,
    this.isSpeaking = false,
    this.onLongPress,
  });

  final ChatMessageModel message;
  final String? streamingProgress;
  final bool isSpeaking;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.role == ChatMessageRole.user;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.86,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isUser
                  ? scheme.primary
                  : context.appColors.floatingSurface,
              borderRadius: BorderRadius.circular(8),
              border: isUser
                  ? null
                  : Border.all(
                      color: isSpeaking
                          ? scheme.primary.withValues(alpha: 0.42)
                          : scheme.onSurface.withValues(alpha: 0.08),
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: _BubbleContent(
                message: message,
                streamingProgress: streamingProgress,
                isSpeaking: isSpeaking,
                textColor: isUser ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.message,
    required this.streamingProgress,
    required this.isSpeaking,
    required this.textColor,
  });

  final ChatMessageModel message;
  final String? streamingProgress;
  final bool isSpeaking;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isStreaming = message.status == ChatMessageStatus.streaming;
    final content = message.content.trim();
    final progress = streamingProgress?.trim();
    final showThinkingPlaceholder =
        isStreaming &&
        (progress == null || progress.isEmpty) &&
        (content.isEmpty || content == 'Thinking...');
    if (showThinkingPlaceholder) {
      return _ThinkingPlaceholder(textColor: textColor);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSpeaking)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.volume_up,
                  size: 14,
                  color: textColor.withValues(alpha: 0.86),
                ),
                const SizedBox(width: 5),
                Text(
                  'Speaking',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.86),
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        if (isStreaming)
          _StreamingProgress(
            text: progress?.isNotEmpty == true
                ? progress!
                : 'Codex turn running',
            textColor: textColor,
          ),
        if (content.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isStreaming ? 5 : 0),
            child: Text(
              message.content,
              style: TextStyle(
                height: 1.28,
                color: textColor,
                fontWeight: isStreaming ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}

class _StreamingProgress extends StatefulWidget {
  const _StreamingProgress({required this.text, required this.textColor});

  final String text;
  final Color textColor;

  @override
  State<_StreamingProgress> createState() => _StreamingProgressState();
}

class _StreamingProgressState extends State<_StreamingProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.58,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Codex thinking',
            style: TextStyle(
              color: widget.textColor.withValues(alpha: 0.82),
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.text,
            style: TextStyle(
              color: widget.textColor.withValues(alpha: 0.9),
              height: 1.25,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingPlaceholder extends StatefulWidget {
  const _ThinkingPlaceholder({required this.textColor});

  final Color textColor;

  @override
  State<_ThinkingPlaceholder> createState() => _ThinkingPlaceholderState();
}

class _ThinkingPlaceholderState extends State<_ThinkingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.48,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.textColor.withValues(alpha: 0.72),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Codex thinking',
            style: TextStyle(
              color: widget.textColor.withValues(alpha: 0.88),
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
