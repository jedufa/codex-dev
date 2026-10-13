import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_pill.dart';
import '../connection/connection_controller.dart';
import '../connection/connection_setup_panel.dart';
import 'chat_controller.dart';
import 'chat_models.dart';
import 'chat_speech_controller.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_status_banner.dart';
import 'widgets/chat_thread_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.controller,
    required this.connectionController,
    required this.onPaired,
    this.speechController,
  });

  final ChatController controller;
  final ConnectionController connectionController;
  final Future<void> Function() onPaired;
  final ChatSpeechController? speechController;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _draftController = TextEditingController();
  ChatSpeechController? _ownedSpeechController;
  late ChatSpeechController _speechController;
  late AgentThread _speechThread;

  ChatController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _ownedSpeechController = widget.speechController == null
        ? ChatSpeechController()
        : null;
    _speechController = widget.speechController ?? _ownedSpeechController!;
    _speechThread = widget.controller.selectedThread;
    widget.controller.addListener(_handleControllerChanged);
    _speechController.addListener(_handleSpeechChanged);
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _speechThread = widget.controller.selectedThread;
    }
    _ownedSpeechController ??= widget.speechController == null
        ? ChatSpeechController()
        : null;
    final nextSpeechController =
        widget.speechController ?? _ownedSpeechController!;
    if (!identical(_speechController, nextSpeechController)) {
      _speechController.removeListener(_handleSpeechChanged);
      _speechController = nextSpeechController;
      _speechController.addListener(_handleSpeechChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _speechController.removeListener(_handleSpeechChanged);
    _ownedSpeechController?.dispose();
    _draftController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    // Sync before build so the browser input client receives the new draft.
    final draft = controller.active.draft;
    if (_draftController.text != draft) {
      _draftController.value = TextEditingValue(
        text: draft,
        selection: TextSelection.collapsed(offset: draft.length),
      );
    }
    final selectedThread = widget.controller.selectedThread;
    if (_speechThread == selectedThread) return;
    _speechThread = selectedThread;
    if (_speechController.isSpeaking) {
      _speechController.stop();
    }
  }

  void _handleSpeechChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleMessageLongPress(ChatMessageModel message) async {
    if (message.role == ChatMessageRole.user) {
      await Clipboard.setData(ClipboardData(text: message.content));
      _showSpeechSnack('Bubble copied');
      return;
    }
    if (_speechController.activeMessageId == message.id) {
      await _speechController.stop();
      _showSpeechSnack('Speech stopped');
      return;
    }
    final error = await _speechController.speakMessage(
      messageId: message.id,
      text: message.content,
    );
    if (error != null) _showSpeechSnack(error);
  }

  Future<void> _stopSpeech() async {
    await _speechController.stop();
    _showSpeechSnack('Speech stopped');
  }

  void _showSpeechSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.connectionController.isPaired) {
      return ConnectionSetupPanel(
        controller: widget.connectionController,
        onPaired: widget.onPaired,
        compact: true,
      );
    }
    final active = controller.active;
    return Column(
      children: [
        _ThreadStrip(
          controller: controller,
          connectionController: widget.connectionController,
        ),
        ChatThreadHeader(
          workingDirectory: active.workingDirectory,
          modelLabel: active.modelLabel,
          selectedProjectId: active.selectedProjectId,
          selectedModelId: active.selectedModelId,
          projects: controller.projects,
          modelPresets: controller.modelPresets,
          onDirectoryChanged: controller.updateWorkingDirectory,
          onProjectAdded: controller.addProject,
          onProjectSelected: controller.selectProject,
          onModelChanged: controller.updateModel,
        ),
        if (active.errorMessage != null)
          ChatStatusBanner(
            message: 'Error: ${active.errorMessage}',
            tone: StatusTone.error,
          )
        else if (active.streamingProgress != null)
          ChatStatusBanner(
            message: active.streamingProgress!,
            tone: StatusTone.warning,
          ),
        if (active.recoveredActiveTurn)
          ChatStatusBanner(
            message:
                'Simulated recovered turn. Stop clears it in this session.',
            tone: StatusTone.warning,
          ),
        if (active.queueWarning != null)
          ChatStatusBanner(
            message: active.queueWarning!,
            tone: StatusTone.warning,
          ),
        if (active.queuedPrompts.isNotEmpty)
          _QueuedPromptStrip(
            prompts: active.queuedPrompts,
            onRemove: controller.removeQueuedPrompt,
            onClear: controller.clearActiveQueue,
          ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ChatMessageList(
                messages: active.messages,
                streamingProgress: active.streamingProgress,
                activeSpeechMessageId: _speechController.activeMessageId,
                onMessageLongPress: _handleMessageLongPress,
              ),
              if (controller.loaded && active.messages.isEmpty)
                const ChatEmptyState(),
              if (!controller.loaded)
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              SpeechStopOverlay(
                visible: _speechController.isSpeaking,
                onStop: _stopSpeech,
              ),
            ],
          ),
        ),
        ChatInputBar(
          key: ValueKey('chat-input-bar-${controller.selectedThread.key}'),
          controller: _draftController,
          enabled: true,
          isSending: active.isSending,
          onChanged: controller.updateDraft,
          onSend: controller.sendActiveDraft,
          onCancel: controller.cancelActiveTurn,
        ),
      ],
    );
  }
}

class SpeechStopOverlay extends StatelessWidget {
  const SpeechStopOverlay({
    super.key,
    required this.visible,
    required this.onStop,
  });

  final bool visible;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      key: const Key('speech-stop-overlay'),
      right: 12,
      top: 12,
      child: Material(
        color: scheme.error,
        elevation: 8,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          key: const Key('speech-stop-button'),
          tooltip: 'Stop speech',
          onPressed: onStop,
          icon: Icon(Icons.stop, color: scheme.onError),
        ),
      ),
    );
  }
}

class _QueuedPromptStrip extends StatelessWidget {
  const _QueuedPromptStrip({
    required this.prompts,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> prompts;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('queued-prompt-strip'),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          Text(
            'Queue ${prompts.length}/$chatPromptQueueMaxDepth',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => InputChip(
                  label: Text(
                    prompts[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  onDeleted: () => onRemove(index),
                ),
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemCount: prompts.length,
              ),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _ThreadStrip extends StatelessWidget {
  const _ThreadStrip({
    required this.controller,
    required this.connectionController,
  });

  final ChatController controller;
  final ConnectionController connectionController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final thread = controller.tabs[index];
                final state = controller.threads[thread]!;
                final selected = controller.selectedThread == thread;
                return _AgentThreadPill(
                  thread: thread,
                  selected: selected,
                  hasUnread: state.hasUnread,
                  scheme: scheme,
                  colors: colors,
                  onTap: () => controller.selectThread(thread),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemCount: controller.tabs.length,
            ),
          ),
          _ServerHealthDot(connectionController: connectionController),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AgentThreadPill extends StatelessWidget {
  const _AgentThreadPill({
    required this.thread,
    required this.selected,
    required this.hasUnread,
    required this.scheme,
    required this.colors,
    required this.onTap,
  });

  final AgentThread thread;
  final bool selected;
  final bool hasUnread;
  final ColorScheme scheme;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? scheme.primary.withValues(alpha: 0.40)
        : hasUnread
        ? scheme.primary.withValues(alpha: 0.24)
        : scheme.outline.withValues(alpha: 0.24);
    final textColor = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.88);

    return Material(
      key: Key('agent-tab-${thread.key}'),
      color: selected ? colors.selectedSegment : colors.floatingSurface,
      elevation: selected ? 3 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                thread.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                  height: 1,
                ),
              ),
              if (hasUnread && !selected) ...[
                const SizedBox(width: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerHealthDot extends StatelessWidget {
  const _ServerHealthDot({required this.connectionController});

  final ConnectionController connectionController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final dotColor = !connectionController.isPaired
        ? scheme.error
        : connectionController.serverHealthKnown
        ? (connectionController.serverHealthy ? colors.success : scheme.error)
        : colors.neutral;
    final status = connectionController.serverStatus;
    final tooltip = !connectionController.isPaired
        ? 'Server disconnected'
        : status == null
        ? 'Server status unknown'
        : '${status.serverUrl} - ${status.health}';
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        key: const Key('chat-server-health-dot'),
        onTap: connectionController.checkingServer
            ? null
            : () => connectionController.refreshServerStatus(),
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: connectionController.checkingServer ? 10 : 8,
            height: connectionController.checkingServer ? 10 : 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Start a simulated turn',
      message: 'Pick C1-C4 and try a message. All replies are scripted.',
    );
  }
}
