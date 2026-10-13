import 'dart:async';

import '../features/activity/activity_models.dart';
import '../features/chat/chat_models.dart';
import '../features/connection/connection_models.dart';
import '../features/connection/paired_server_store.dart';
import '../features/settings/settings_models.dart';
import '../features/workspace/workspace_models.dart';
import 'codex_api_client.dart';

class MockCodexApiClient implements CodexApiClient {
  MockCodexApiClient({
    this.disconnected = false,
    this.codexUsesApiKey = false,
    this.settingsThrows = false,
    this.emptyProjects = false,
    this.modelEndpointThrows = false,
    this.recoveredActiveTurn = false,
    this.pairingFails = false,
    this.revokeFails = false,
    this.unauthorized = false,
    this.responseDelay = const Duration(milliseconds: 1400),
  });

  final bool disconnected;
  final bool codexUsesApiKey;
  final bool settingsThrows;
  final bool emptyProjects;
  final bool modelEndpointThrows;
  final bool recoveredActiveTurn;
  final bool pairingFails;
  final bool revokeFails;
  final bool unauthorized;
  final Duration responseDelay;
  PairedServerConnection? pairedConnection;
  bool revokeCalled = false;

  @override
  void configureConnection(PairedServerConnection connection) {
    pairedConnection = connection;
  }

  @override
  void clearConnection() {
    pairedConnection = null;
  }

  @override
  Future<PairedServerConnection> pairServer(PairServerInput input) async {
    if (pairingFails) throw StateError('invalid pairing code');
    final connection = demoConnection();
    configureConnection(connection);
    return connection;
  }

  @override
  Future<void> revokeCurrentPairing() async {
    revokeCalled = true;
    if (revokeFails) throw StateError('server unreachable while revoking');
    clearConnection();
  }

  @override
  Future<ServerStatus> getServerStatus() async {
    if (unauthorized) {
      throw StateError(
        'Mobile pairing expired or was revoked. Reconnect to this server.',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return ServerStatus(
      connected: !disconnected,
      serverUrl: 'In-process simulation',
      version: disconnected ? 'unknown' : 'simulated 0.1.0',
      health: disconnected ? 'Server unreachable' : 'Simulated ready',
      lastCheckedAt: DateTime.now(),
    );
  }

  @override
  Future<SettingsStatus> getSettingsStatus() async {
    if (settingsThrows) {
      throw StateError('Server endpoint unavailable');
    }
    if (unauthorized) {
      throw StateError(
        'Mobile pairing expired or was revoked. Reconnect to this server.',
      );
    }
    return SettingsStatus(
      server: await getServerStatus(),
      codex: CodexStatus(
        authModeConfigured: codexUsesApiKey ? 'api_key' : 'chatgpt',
        authModeEffective: codexUsesApiKey ? 'api_key' : 'chatgpt',
        billingPath: codexUsesApiKey
            ? 'openai_platform'
            : 'chatgpt_codex_allowance',
        chatgptAuthAvailable: !codexUsesApiKey,
        apiKeyVisibleToCodex: codexUsesApiKey,
        warningMessage: codexUsesApiKey
            ? 'API-key Codex mode can bill OpenAI Platform usage. Keep this explicit before execution is enabled.'
            : null,
      ),
      openAiApi: const OpenAiApiStatus(
        apiKeyAvailable: false,
        apiKeySource: 'none',
        usedFor: 'API features and embeddings when the server enables them.',
        billingPath: 'openai_platform',
      ),
      vault: const VaultStatus(
        configured: false,
        locked: true,
        secretsAvailableSummary:
            'No vault or credentials in this demonstration.',
      ),
      deployment: const DeploymentStatus(
        configured: false,
        sshHost: 'Not configured',
        installPath: 'Not configured',
        lastDeployStatus:
            'Deployment is a backend placeholder in this Flutter pass.',
      ),
      embeddings: const EmbeddingsStatus(
        enabled: false,
        provider: 'openai',
        indexStatus: 'not_configured',
        apiKeyRequired: true,
        billingPath: 'disabled',
      ),
    );
  }

  @override
  Future<List<AgentThread>> listThreads() async => AgentThread.values;

  @override
  Future<List<ProjectSummary>> listProjects() async => emptyProjects
      ? const []
      : const [
          ProjectSummary(
            id: 'garden-notes',
            displayName: 'garden-notes',
            rootPath: '/demo/garden-notes',
            readiness: 'ready',
          ),
          ProjectSummary(
            id: 'pocket-recipes',
            displayName: 'pocket-recipes',
            rootPath: '/demo/pocket-recipes',
            readiness: 'ready',
          ),
        ];

  @override
  Future<List<ProjectSummary>> addProject({
    required String name,
    required String rootPath,
  }) async {
    final existing = await listProjects();
    final trimmedRoot = rootPath.trim();
    if (trimmedRoot.isEmpty) return existing;
    final displayName = name.trim().isEmpty
        ? trimmedRoot.split('/').where((part) => part.isNotEmpty).last
        : name.trim();
    return [
      ...existing.where((project) => project.rootPath != trimmedRoot),
      ProjectSummary(
        id: displayName.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9._:-]+'),
          '-',
        ),
        displayName: displayName,
        rootPath: trimmedRoot,
        readiness: 'ready',
      ),
    ];
  }

  @override
  Future<List<CodexModelPreset>> listModelPresets() async {
    if (modelEndpointThrows) throw StateError('model endpoint unavailable');
    return CodexModelPreset.fallbackPresets;
  }

  @override
  Future<ChatThreadModel> getThread(String threadId) async {
    final thread = AgentThread.values.firstWhere(
      (item) => item.threadId == threadId,
      orElse: () => AgentThread.c1,
    );
    return ChatThreadModel(
      thread: thread,
      messages: _seedMessages(thread),
      workingDirectory: emptyProjects ? '' : '/demo/garden-notes',
      selectedProjectId: emptyProjects ? null : 'garden-notes',
      selectedModelId: 'gpt-5.5-medium',
      modelLabel: 'Demo · balanced',
      isSending: recoveredActiveTurn && thread == AgentThread.c1,
      recoveredActiveTurn: recoveredActiveTurn && thread == AgentThread.c1,
      streamingProgress: recoveredActiveTurn && thread == AgentThread.c1
          ? 'Turn still running on server.'
          : null,
    );
  }

  @override
  Future<ChatMessageModel> sendMessage(String threadId, String message) async {
    await Future<void>.delayed(responseDelay);
    return ChatMessageModel(
      id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
      threadId: threadId,
      role: ChatMessageRole.assistant,
      status: ChatMessageStatus.complete,
      createdAt: DateTime.now(),
      content:
          'Simulated reply: your request stays in memory.\n\n'
          'A small plan\n\n1. Review the fictional garden notes.\n2. Sketch a clearer task list.\n3. Keep the next step easy to find.\n\n'
          'Example reference: notes/plan.md. No file was opened or changed.',
    );
  }

  @override
  Stream<ChatMessageModel> streamTurn(
    String threadId,
    String message, {
    String? workingDirectory,
    CodexModelPreset? modelPreset,
  }) async* {
    yield ChatMessageModel(
      id: 'simulated-progress',
      threadId: threadId,
      role: ChatMessageRole.assistant,
      content: 'Sketching a plan from fictional notes...',
      status: ChatMessageStatus.streaming,
      createdAt: DateTime.now(),
      streamingProgress: 'Simulated progress · no tools are running',
    );
    yield await sendMessage(threadId, message);
  }

  @override
  Future<void> cancelTurn(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  @override
  Future<WorkspaceStatus> getWorkspaceStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return const WorkspaceStatus(
      projectName: 'garden-notes',
      projectRoot: '/demo/garden-notes',
      serverUrl: 'In-process simulation',
      summary: 'Phone-first control surface for chat-driven project work.',
      filesChanged: 0,
    );
  }

  @override
  Future<List<ActivityItem>> getActivity() async {
    final now = DateTime.now();
    return [
      ActivityItem(
        id: 'server',
        title: disconnected ? 'Server disconnected' : 'Server heartbeat',
        detail: disconnected
            ? 'Server unreachable mock state.'
            : 'Mock server status refreshed.',
        level: disconnected ? ActivityLevel.error : ActivityLevel.success,
        createdAt: now,
      ),
      ActivityItem(
        id: 'openai-api',
        title: 'Simulation loaded',
        detail: 'All example state stays in this app process.',
        level: ActivityLevel.success,
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      ActivityItem(
        id: 'codex',
        title: 'Fictional workspace ready',
        detail: 'No files are accessed or modified.',
        level: ActivityLevel.info,
        createdAt: now.subtract(const Duration(minutes: 9)),
      ),
    ];
  }

  @override
  Future<VaultStatus> getVaultStatus() async =>
      (await getSettingsStatus()).vault;

  @override
  Future<DeploymentStatus> getDeploymentStatus() async =>
      (await getSettingsStatus()).deployment;

  @override
  Future<DeploymentValidationResult> validateDeployment(
    DeploymentValidationInput input,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final errors = <String>[
      if (input.host.trim().isEmpty) 'ssh.host is required',
      if (input.user.trim().isEmpty) 'ssh.user is required',
      if (input.targetInstallDir.trim().isEmpty)
        'target_install_dir is required',
      if (input.pairingToken.trim().isEmpty) 'pairing_token is required',
    ];
    return DeploymentValidationResult(
      ok: errors.isEmpty,
      errors: errors,
      warnings: const [],
      authMethod: input.authMethod.name,
    );
  }

  List<ChatMessageModel> _seedMessages(AgentThread thread) {
    if (thread != AgentThread.c1) return const [];
    final now = DateTime.now().subtract(const Duration(minutes: 6));
    return [
      ChatMessageModel(
        id: 'seed-user',
        threadId: thread.threadId,
        role: ChatMessageRole.user,
        status: ChatMessageStatus.complete,
        createdAt: now,
        content:
            'Help me organize the next few improvements to my garden notes app.',
      ),
      ChatMessageModel(
        id: 'seed-assistant',
        threadId: thread.threadId,
        role: ChatMessageRole.assistant,
        status: ChatMessageStatus.complete,
        createdAt: now.add(const Duration(seconds: 20)),
        content:
            'Here is a fictional starting point.\n\nGarden Notes could use a simpler plant list, a weekly reminder and a small progress view.\n\nTry a message below, switch between C1–C4, or simulate a disconnect in settings. These replies are scripted, not AI-generated.',
      ),
    ];
  }
}
