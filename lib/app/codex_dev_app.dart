import 'package:flutter/material.dart';

import '../features/activity/activity_controller.dart';
import '../features/chat/chat_controller.dart';
import '../features/connection/connection_controller.dart';
import '../features/connection/paired_server_store.dart';
import '../features/settings/settings_controller.dart';
import '../features/shell/codex_shell_screen.dart';
import '../features/shell/shell_controller.dart';
import '../features/workspace/workspace_controller.dart';
import '../services/mock_codex_api_client.dart';
import 'app_theme.dart';

class CodexDevApp extends StatefulWidget {
  const CodexDevApp({
    super.key,
    required this.apiClient,
    this.pairedServerStore,
  });

  final MockCodexApiClient apiClient;
  final PairedServerStore? pairedServerStore;

  @override
  State<CodexDevApp> createState() => _CodexDevAppState();
}

class _CodexDevAppState extends State<CodexDevApp> {
  late final ShellController shellController = ShellController();
  late final ConnectionController connectionController = ConnectionController(
    apiClient: widget.apiClient,
    store:
        widget.pairedServerStore ?? MemoryPairedServerStore(demoConnection()),
  );
  late final ActivityController activityController = ActivityController(
    apiClient: widget.apiClient,
  );
  late final ChatController chatController = ChatController(
    apiClient: widget.apiClient,
    recordActivity: activityController.record,
  );
  late final WorkspaceController workspaceController = WorkspaceController(
    apiClient: widget.apiClient,
  );
  late final SettingsController settingsController = SettingsController(
    apiClient: widget.apiClient,
  );

  @override
  void initState() {
    super.initState();
    _loadConnection();
  }

  Future<void> _loadConnection() async {
    await connectionController.load();
    if (connectionController.isPaired) {
      await loadServerControllers();
    }
  }

  Future<void> loadServerControllers() async {
    await Future.wait([
      if (!chatController.loaded) chatController.load(),
      workspaceController.load(),
      activityController.load(),
      settingsController.load(),
    ]);
  }

  @override
  void dispose() {
    shellController.dispose();
    connectionController.dispose();
    chatController.dispose();
    workspaceController.dispose();
    activityController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Codex Dev · Simulated demo',
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: CodexShellScreen(
        shellController: shellController,
        chatController: chatController,
        workspaceController: workspaceController,
        activityController: activityController,
        settingsController: settingsController,
        connectionController: connectionController,
        onPaired: loadServerControllers,
      ),
    );
  }
}
