import 'package:flutter/material.dart';

import '../chat_models.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.streamingProgress,
    this.activeSpeechMessageId,
    this.onMessageLongPress,
  });

  final List<ChatMessageModel> messages;
  final String? streamingProgress;
  final String? activeSpeechMessageId;
  final ValueChanged<ChatMessageModel>? onMessageLongPress;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  static const _bottomTolerance = 56.0;

  final ScrollController _scrollController = ScrollController();
  bool _showJumpToLatest = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollChanged);
    _scheduleScrollToBottom(animated: false);
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedThread =
        _threadIdFor(oldWidget.messages) != _threadIdFor(widget.messages);
    final messageTailChanged =
        oldWidget.messages.length != widget.messages.length ||
        _lastMessageSignature(oldWidget.messages) !=
            _lastMessageSignature(widget.messages);

    if (changedThread || oldWidget.messages.isEmpty) {
      _scheduleScrollToBottom(animated: false);
    } else if (messageTailChanged && _isAtBottom) {
      _scheduleScrollToBottom(animated: true);
    } else {
      _scheduleJumpButtonUpdate();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScrollChanged)
      ..dispose();
    super.dispose();
  }

  bool get _isAtBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= _bottomTolerance;
  }

  void _handleScrollChanged() {
    _setJumpButtonVisible(!_isAtBottom);
  }

  void _setJumpButtonVisible(bool visible) {
    if (_showJumpToLatest == visible || !mounted) return;
    setState(() => _showJumpToLatest = visible);
  }

  void _scheduleJumpButtonUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setJumpButtonVisible(!_isAtBottom);
    });
  }

  void _scheduleScrollToBottom({required bool animated, int retries = 1}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (target <= 0) {
        _setJumpButtonVisible(false);
        return;
      }
      if (animated) {
        _scrollController
            .animateTo(
              target,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() => _settleAtBottom(retries));
      } else {
        _scrollController.jumpTo(target);
        _settleAtBottom(retries);
      }
    });
  }

  void _settleAtBottom(int retries) {
    if (retries > 0) {
      _scheduleScrollToBottom(animated: false, retries: retries - 1);
      return;
    }
    _scheduleJumpButtonUpdate();
  }

  void _scrollToLatest() {
    _scheduleScrollToBottom(animated: true);
  }

  static String _threadIdFor(List<ChatMessageModel> messages) {
    return messages.isEmpty ? '' : messages.last.threadId;
  }

  static String _lastMessageSignature(List<ChatMessageModel> messages) {
    if (messages.isEmpty) return '';
    final message = messages.last;
    return [
      message.id,
      message.status.name,
      message.content,
      message.streamingProgress ?? '',
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(8, 6, 8, 12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = (constraints.maxHeight - padding.vertical).clamp(
          0.0,
          double.infinity,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              key: const Key('chat-message-list'),
              controller: _scrollController,
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        var index = 0;
                        index < widget.messages.length;
                        index++
                      ) ...[
                        ChatMessageBubble(
                          message: widget.messages[index],
                          streamingProgress:
                              widget.messages[index].status ==
                                  ChatMessageStatus.streaming
                              ? widget.messages[index].streamingProgress ??
                                    widget.streamingProgress
                              : null,
                          isSpeaking:
                              widget.activeSpeechMessageId ==
                              widget.messages[index].id,
                          onLongPress: widget.onMessageLongPress == null
                              ? null
                              : () => widget.onMessageLongPress!(
                                  widget.messages[index],
                                ),
                        ),
                        if (index != widget.messages.length - 1)
                          const SizedBox(height: 7),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_showJumpToLatest)
              Positioned(
                key: const Key('chat-scroll-to-bottom-button'),
                left: 0,
                right: 0,
                bottom: 14,
                child: Center(
                  child: _JumpToLatestButton(onPressed: _scrollToLatest),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _JumpToLatestButton extends StatelessWidget {
  const _JumpToLatestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 5,
      shape: CircleBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: 'Jump to latest',
        iconSize: 22,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: scheme.onSurface.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
