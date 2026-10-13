class ServerStatus {
  const ServerStatus({
    required this.connected,
    required this.serverUrl,
    required this.version,
    required this.health,
    required this.lastCheckedAt,
  });

  final bool connected;
  final String serverUrl;
  final String version;
  final String health;
  final DateTime lastCheckedAt;
}

class CodexStatus {
  const CodexStatus({
    required this.authModeConfigured,
    required this.authModeEffective,
    required this.billingPath,
    required this.chatgptAuthAvailable,
    required this.apiKeyVisibleToCodex,
    this.warningMessage,
  });

  final String authModeConfigured;
  final String authModeEffective;
  final String billingPath;
  final bool chatgptAuthAvailable;
  final bool apiKeyVisibleToCodex;
  final String? warningMessage;

  bool get available => authModeEffective != 'unavailable';
  bool get billsOpenAiPlatform => billingPath == 'openai_platform';
  bool get usesChatGptAllowance => billingPath == 'chatgpt_codex_allowance';
}

class OpenAiApiStatus {
  const OpenAiApiStatus({
    required this.apiKeyAvailable,
    required this.apiKeySource,
    required this.usedFor,
    required this.billingPath,
  });

  final bool apiKeyAvailable;
  final String apiKeySource;
  final String usedFor;
  final String billingPath;

  bool get billsOpenAiPlatform => billingPath == 'openai_platform';
}

class VaultStatus {
  const VaultStatus({
    required this.configured,
    required this.locked,
    required this.secretsAvailableSummary,
  });

  final bool configured;
  final bool locked;
  final String secretsAvailableSummary;
}

class DeploymentStatus {
  const DeploymentStatus({
    required this.configured,
    required this.sshHost,
    required this.installPath,
    required this.lastDeployStatus,
    this.lastDeployAt,
  });

  final bool configured;
  final String sshHost;
  final String installPath;
  final String lastDeployStatus;
  final DateTime? lastDeployAt;
}

class EmbeddingsStatus {
  const EmbeddingsStatus({
    required this.enabled,
    required this.provider,
    required this.indexStatus,
    required this.apiKeyRequired,
    required this.billingPath,
    this.lastIndexedAt,
    this.indexedFiles,
    this.indexedChunks,
    this.lastError,
  });

  final bool enabled;
  final String provider;
  final String indexStatus;
  final bool apiKeyRequired;
  final String billingPath;
  final DateTime? lastIndexedAt;
  final int? indexedFiles;
  final int? indexedChunks;
  final String? lastError;
}

enum DeploymentAuthMethod { privateKey, password, vaultSecret }

class DeploymentValidationInput {
  const DeploymentValidationInput({
    required this.host,
    required this.port,
    required this.user,
    required this.authMethod,
    required this.targetInstallDir,
    required this.pairingToken,
    this.storeSecretsInVault = true,
  });

  final String host;
  final int port;
  final String user;
  final DeploymentAuthMethod authMethod;
  final String targetInstallDir;
  final String pairingToken;
  final bool storeSecretsInVault;
}

class DeploymentValidationResult {
  const DeploymentValidationResult({
    required this.ok,
    required this.errors,
    required this.warnings,
    required this.authMethod,
  });

  final bool ok;
  final List<String> errors;
  final List<String> warnings;
  final String authMethod;
}

class SettingsStatus {
  const SettingsStatus({
    required this.server,
    required this.codex,
    required this.openAiApi,
    required this.vault,
    required this.deployment,
    required this.embeddings,
  });

  final ServerStatus server;
  final CodexStatus codex;
  final OpenAiApiStatus openAiApi;
  final VaultStatus vault;
  final DeploymentStatus deployment;
  final EmbeddingsStatus embeddings;
}
