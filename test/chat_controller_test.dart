import 'dart:async';

import 'package:codex_dev/features/activity/activity_models.dart';
import 'package:codex_dev/features/chat/chat_controller.dart';
import 'package:codex_dev/features/chat/chat_models.dart';
import 'package:codex_dev/features/connection/connection_models.dart';
import 'package:codex_dev/features/settings/settings_models.dart';
import 'package:codex_dev/features/workspace/workspace_models.dart';
import 'package:codex_dev/services/codex_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recovers xhigh Codex model preset ids', () {
    final preset = CodexModelPreset.fromWireValue('gpt-5.4-mini-xhigh');

    expect(preset.id, 'gpt-5.4-mini-xhigh');
    expect(preset.model, 'gpt-5.4-mini');
    expect(preset.reasoningEffort, 'xhigh');
    expect(preset.label, 'GPT 5.4 Mini XHigh');
  });

  test(
    'loads threads, sends streaming response, and marks unread off-tab',
    () async {
      final api = _RecordingApiClient();
      final controller = ChatController(apiClient: api);
      await controller.load();

      controller.updateDraft('build it');
      controller.selectThread(AgentThread.c2);
      controller.updateDraft('other tab');
      controller.selectThread(AgentThread.c1);
      await controller.sendActiveDraft();

      expect(controller.active.draft, isEmpty);
      expect(controller.active.messages.last.content, 'partial complete');
      expect(controller.active.isSending, isFalse);
      expect(api.sentThreadIds, [AgentThread.c1.threadId]);
    },
  );

  test(
    'cancelActiveTurn stops local rendering and calls backend cancel',
    () async {
      final api = _RecordingApiClient(streamCompleter: Completer<void>());
      final controller = ChatController(apiClient: api);
      await controller.load();

      controller.updateDraft('long task');
      final sendFuture = controller.sendActiveDraft();
      await Future<void>.delayed(Duration.zero);
      expect(controller.active.isSending, isTrue);

      await controller.cancelActiveTurn();

      expect(api.cancelledThreadIds, [AgentThread.c1.threadId]);
      expect(controller.active.isSending, isFalse);
      expect(controller.active.errorMessage, contains('Simulation stopped'));
      api.streamCompleter!.complete();
      await sendFuture;
    },
  );

  test('shows live Codex commentary while a turn is streaming', () async {
    final api = _RecordingApiClient(streamCompleter: Completer<void>());
    final controller = ChatController(apiClient: api);
    await controller.load();

    controller.updateDraft('inspect it');
    final sendFuture = controller.sendActiveDraft();
    await Future<void>.delayed(Duration.zero);

    expect(controller.active.isSending, isTrue);
    expect(controller.active.streamingProgress, 'Reading files');
    expect(controller.active.messages.last.content, 'partial');

    api.streamCompleter!.complete();
    await sendFuture;
  });

  test('marks off-tab unread only after the Codex turn finishes', () async {
    final api = _RecordingApiClient(streamCompleter: Completer<void>());
    final controller = ChatController(apiClient: api);
    await controller.load();

    controller.selectThread(AgentThread.c2);
    controller.updateDraft('inspect off tab');
    final sendFuture = controller.sendActiveDraft();
    controller.selectThread(AgentThread.c1);
    await Future<void>.delayed(Duration.zero);

    expect(controller.threads[AgentThread.c2]!.isSending, isTrue);
    expect(
      controller.threads[AgentThread.c2]!.streamingProgress,
      'Reading files',
    );
    expect(controller.threads[AgentThread.c2]!.hasUnread, isFalse);

    api.streamCompleter!.complete();
    await sendFuture;

    expect(controller.threads[AgentThread.c2]!.isSending, isFalse);
    expect(controller.threads[AgentThread.c2]!.hasUnread, isTrue);
  });

  test('sending during active stream queues and preserves order', () async {
    final api = _RecordingApiClient(streamCompleter: Completer<void>());
    final controller = ChatController(apiClient: api);
    await controller.load();

    controller.updateDraft('first');
    final sendFuture = controller.sendActiveDraft();
    await Future<void>.delayed(Duration.zero);

    controller.updateDraft('second');
    await controller.sendActiveDraft();

    expect(controller.active.queuedPrompts, ['second']);
    expect(controller.active.draft, isEmpty);
    api.streamCompleter!.complete();
    await sendFuture;

    expect(api.sentMessages, ['first', 'second']);
    expect(controller.active.queuedPrompts, isEmpty);
  });

  test('stop cancels active turn but preserves queued prompts', () async {
    final api = _RecordingApiClient(streamCompleter: Completer<void>());
    final controller = ChatController(apiClient: api);
    await controller.load();

    controller.updateDraft('first');
    final sendFuture = controller.sendActiveDraft();
    await Future<void>.delayed(Duration.zero);
    controller.updateDraft('second');
    await controller.sendActiveDraft();

    await controller.cancelActiveTurn();
    expect(controller.active.queuedPrompts, ['second']);
    expect(api.cancelledThreadIds, [AgentThread.c1.threadId]);

    api.streamCompleter!.complete();
    await sendFuture;
    expect(controller.active.queuedPrompts, ['second']);
  });

  test(
    'clear queue removes queued prompts and max depth is enforced',
    () async {
      final api = _RecordingApiClient(streamCompleter: Completer<void>());
      final controller = ChatController(apiClient: api);
      await controller.load();

      controller.updateDraft('active');
      final sendFuture = controller.sendActiveDraft();
      await Future<void>.delayed(Duration.zero);

      for (var i = 0; i < chatPromptQueueMaxDepth + 1; i += 1) {
        controller.updateDraft('queued $i');
        await controller.sendActiveDraft();
      }
      expect(
        controller.active.queuedPrompts,
        hasLength(chatPromptQueueMaxDepth),
      );
      expect(controller.active.queueWarning, contains('Queue full'));

      controller.clearActiveQueue();
      expect(controller.active.queuedPrompts, isEmpty);
      api.streamCompleter!.complete();
      await sendFuture;
    },
  );

  test('adds project and selects it for active thread', () async {
    final api = _RecordingApiClient();
    final controller = ChatController(apiClient: api);
    await controller.load();

    await controller.addProject(
      name: 'New Repo',
      rootPath: '/projects/new-repo',
    );

    expect(controller.projects.last.rootPath, '/projects/new-repo');
    expect(controller.active.workingDirectory, '/projects/new-repo');
    expect(controller.active.selectedProjectId, 'New Repo');
    expect(controller.active.errorMessage, isNull);
  });
}

class _RecordingApiClient implements CodexApiClient {
  _RecordingApiClient({this.streamCompleter});

  final Completer<void>? streamCompleter;
  final sentThreadIds = <String>[];
  final sentMessages = <String>[];
  final cancelledThreadIds = <String>[];

  @override
  void configureConnection(PairedServerConnection connection) {}

  @override
  void clearConnection() {}

  @override
  Future<PairedServerConnection> pairServer(PairServerInput input) {
    throw UnimplementedError();
  }

  @override
  Future<void> revokeCurrentPairing() {
    throw UnimplementedError();
  }

  @override
  Future<List<AgentThread>> listThreads() async => AgentThread.values;

  @override
  Future<List<ProjectSummary>> listProjects() async => const [
    ProjectSummary(
      id: 'codex-dev',
      displayName: 'codex-dev',
      rootPath: '/projects/codex-dev',
    ),
  ];

  @override
  Future<List<ProjectSummary>> addProject({
    required String name,
    required String rootPath,
  }) async => [
    const ProjectSummary(
      id: 'codex-dev',
      displayName: 'codex-dev',
      rootPath: '/projects/codex-dev',
    ),
    ProjectSummary(
      id: name.trim().isEmpty ? 'new-repo' : name.trim(),
      displayName: name.trim().isEmpty ? 'new-repo' : name.trim(),
      rootPath: rootPath.trim(),
    ),
  ];

  @override
  Future<List<CodexModelPreset>> listModelPresets() async =>
      CodexModelPreset.fallbackPresets;

  @override
  Future<ChatThreadModel> getThread(String threadId) async {
    final thread = AgentThread.values.firstWhere(
      (item) => item.threadId == threadId,
    );
    return ChatThreadModel(thread: thread, messages: const []);
  }

  @override
  Stream<ChatMessageModel> streamTurn(
    String threadId,
    String message, {
    String? workingDirectory,
    CodexModelPreset? modelPreset,
  }) async* {
    sentThreadIds.add(threadId);
    sentMessages.add(message);
    yield ChatMessageModel(
      id: 'assistant-stream',
      threadId: threadId,
      role: ChatMessageRole.assistant,
      content: '',
      status: ChatMessageStatus.streaming,
      createdAt: DateTime.now(),
      streamingProgress: 'Reading files',
    );
    yield ChatMessageModel(
      id: 'assistant-stream',
      threadId: threadId,
      role: ChatMessageRole.assistant,
      content: 'partial',
      status: ChatMessageStatus.streaming,
      createdAt: DateTime.now(),
    );
    if (streamCompleter != null) {
      await streamCompleter!.future;
    }
    yield ChatMessageModel(
      id: 'assistant-stream',
      threadId: threadId,
      role: ChatMessageRole.assistant,
      content: 'partial complete',
      status: ChatMessageStatus.complete,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> cancelTurn(String threadId) async {
    cancelledThreadIds.add(threadId);
  }

  @override
  Future<ChatMessageModel> sendMessage(String threadId, String message) {
    throw UnimplementedError();
  }

  @override
  Future<ServerStatus> getServerStatus() async => ServerStatus(
    connected: true,
    serverUrl: 'http://127.0.0.1:8798',
    version: 'test',
    health: 'ok',
    lastCheckedAt: DateTime.now(),
  );

  @override
  Future<SettingsStatus> getSettingsStatus() {
    throw UnimplementedError();
  }

  @override
  Future<WorkspaceStatus> getWorkspaceStatus() {
    throw UnimplementedError();
  }

  @override
  Future<List<ActivityItem>> getActivity() {
    throw UnimplementedError();
  }

  @override
  Future<VaultStatus> getVaultStatus() {
    throw UnimplementedError();
  }

  @override
  Future<DeploymentStatus> getDeploymentStatus() {
    throw UnimplementedError();
  }

  @override
  Future<DeploymentValidationResult> validateDeployment(
    DeploymentValidationInput input,
  ) {
    throw UnimplementedError();
  }
}
