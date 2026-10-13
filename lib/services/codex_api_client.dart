import '../features/activity/activity_models.dart';
import '../features/chat/chat_models.dart';
import '../features/connection/connection_models.dart';
import '../features/settings/settings_models.dart';
import '../features/workspace/workspace_models.dart';

abstract class CodexApiClient {
  void configureConnection(PairedServerConnection connection);
  void clearConnection();
  Future<PairedServerConnection> pairServer(PairServerInput input);
  Future<void> revokeCurrentPairing();
  Future<ServerStatus> getServerStatus();
  Future<SettingsStatus> getSettingsStatus();
  Future<List<AgentThread>> listThreads();
  Future<List<ProjectSummary>> listProjects();
  Future<List<ProjectSummary>> addProject({
    required String name,
    required String rootPath,
  });
  Future<List<CodexModelPreset>> listModelPresets();
  Future<ChatThreadModel> getThread(String threadId);
  Future<ChatMessageModel> sendMessage(String threadId, String message);
  Stream<ChatMessageModel> streamTurn(
    String threadId,
    String message, {
    String? workingDirectory,
    CodexModelPreset? modelPreset,
  });
  Future<void> cancelTurn(String threadId);
  Future<WorkspaceStatus> getWorkspaceStatus();
  Future<List<ActivityItem>> getActivity();
  Future<VaultStatus> getVaultStatus();
  Future<DeploymentStatus> getDeploymentStatus();
  Future<DeploymentValidationResult> validateDeployment(
    DeploymentValidationInput input,
  );
}
