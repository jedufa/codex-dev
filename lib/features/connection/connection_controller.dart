import 'package:flutter/foundation.dart';

import '../../services/codex_api_client.dart';
import '../settings/settings_models.dart';
import 'connection_models.dart';
import 'paired_server_store.dart';

class ConnectionController extends ChangeNotifier {
  ConnectionController({required this.apiClient, required this.store});

  final CodexApiClient apiClient;
  final PairedServerStore store;

  PairedServerConnection? connection;
  bool loading = false;
  bool pairing = false;
  bool revoking = false;
  bool checkingServer = false;
  ServerStatus? serverStatus;
  PairingFailure? failure;
  String? revokeFailureMessage;

  bool get isPaired => connection != null;
  bool get serverHealthy => isPaired && serverStatus?.connected == true;
  bool get serverHealthKnown => serverStatus != null;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    connection = await store.load();
    if (connection != null) {
      apiClient.configureConnection(connection!);
      await refreshServerStatus(notify: false);
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> pair(PairServerInput input) async {
    failure = _validate(input);
    if (failure != null) {
      notifyListeners();
      return false;
    }
    pairing = true;
    notifyListeners();
    try {
      final paired = await apiClient.pairServer(input);
      final saved = paired.copyWith(lastSuccessfulConnectionAt: DateTime.now());
      await store.save(saved);
      connection = saved;
      apiClient.configureConnection(saved);
      await refreshServerStatus(notify: false);
      failure = null;
      revokeFailureMessage = null;
      pairing = false;
      notifyListeners();
      return true;
    } catch (error) {
      failure = _failureFromError(error);
      pairing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectLocal() async {
    await store.clear();
    connection = null;
    serverStatus = null;
    apiClient.clearConnection();
    failure = null;
    revokeFailureMessage = null;
    notifyListeners();
  }

  Future<void> disconnect() => disconnectLocal();

  Future<bool> revokeAndDisconnect() async {
    if (connection == null) return true;
    revoking = true;
    revokeFailureMessage = null;
    notifyListeners();
    try {
      await apiClient.revokeCurrentPairing();
      revoking = false;
      await disconnectLocal();
      return true;
    } catch (error) {
      revoking = false;
      revokeFailureMessage =
          'Could not revoke on the server. You can disconnect locally if the server is unreachable.';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshServerStatus({bool notify = true}) async {
    if (connection == null) {
      serverStatus = null;
      checkingServer = false;
      if (notify) notifyListeners();
      return;
    }
    checkingServer = true;
    if (notify) notifyListeners();
    try {
      final status = await apiClient.getServerStatus();
      serverStatus = status;
      if (status.connected) {
        final saved = connection!.copyWith(
          lastSuccessfulConnectionAt: DateTime.now(),
          serverVersion: status.version,
        );
        connection = saved;
        await store.save(saved);
      }
    } catch (error) {
      serverStatus = ServerStatus(
        connected: false,
        serverUrl: connection!.serverUrl,
        version: connection!.serverVersion ?? 'unknown',
        health: 'Server unreachable: $error',
        lastCheckedAt: DateTime.now(),
      );
    }
    checkingServer = false;
    if (notify) notifyListeners();
  }

  PairingFailure? _validate(PairServerInput input) {
    final host = input.host.trim();
    if (host.isEmpty) {
      return const PairingFailure(
        PairingFailureKind.validation,
        'Server address is required.',
      );
    }
    if (host.contains(RegExp(r'\s'))) {
      return const PairingFailure(
        PairingFailureKind.validation,
        'Server address cannot contain spaces.',
      );
    }
    final hasScheme = host.startsWith('http://') || host.startsWith('https://');
    if (hasScheme) {
      final uri = Uri.tryParse(host);
      if (uri == null || uri.host.isEmpty) {
        return const PairingFailure(
          PairingFailureKind.validation,
          'Server address is not valid.',
        );
      }
    } else if (host.contains('/')) {
      return const PairingFailure(
        PairingFailureKind.validation,
        'Use a full http URL when connecting through a gateway path.',
      );
    }
    if (input.port <= 0 || input.port > 65535) {
      return const PairingFailure(
        PairingFailureKind.validation,
        'Port must be between 1 and 65535.',
      );
    }
    if (input.pairingCode.trim().isEmpty) {
      return const PairingFailure(
        PairingFailureKind.validation,
        'Pairing code is required.',
      );
    }
    return null;
  }

  PairingFailure _failureFromError(Object error) {
    final message = error.toString();
    final lower = message.toLowerCase();
    if (lower.contains('consumed') || lower.contains('already used')) {
      return const PairingFailure(
        PairingFailureKind.rejected,
        'Pairing code was already used. Generate a new code on the server.',
      );
    }
    if (lower.contains('expired')) {
      return const PairingFailure(
        PairingFailureKind.expired,
        'Pairing code expired. Run `codex-dev pair` again on the server.',
      );
    }
    if (lower.contains('401') ||
        lower.contains('403') ||
        lower.contains('invalid')) {
      return const PairingFailure(
        PairingFailureKind.rejected,
        'Pairing code was rejected by the server.',
      );
    }
    if (lower.contains('version') || lower.contains('incompatible')) {
      return const PairingFailure(
        PairingFailureKind.incompatible,
        'Server version is not compatible with this app.',
      );
    }
    if (lower.contains('format') || lower.contains('json')) {
      return const PairingFailure(
        PairingFailureKind.malformed,
        'Server returned an unexpected response.',
      );
    }
    return PairingFailure(
      PairingFailureKind.unreachable,
      'Server is unreachable or did not respond. Check the IP address, port, and that `codex-dev start` is running: $message',
    );
  }
}
