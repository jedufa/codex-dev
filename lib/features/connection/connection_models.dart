class PairedServerConnection {
  const PairedServerConnection({
    required this.serverUrl,
    required this.accessToken,
    required this.pairedAt,
    this.lastSuccessfulConnectionAt,
    this.serverVersion,
  });

  final String serverUrl;
  final String accessToken;
  final DateTime pairedAt;
  final DateTime? lastSuccessfulConnectionAt;
  final String? serverVersion;

  PairedServerConnection copyWith({
    String? serverUrl,
    String? accessToken,
    DateTime? pairedAt,
    DateTime? lastSuccessfulConnectionAt,
    String? serverVersion,
  }) {
    return PairedServerConnection(
      serverUrl: serverUrl ?? this.serverUrl,
      accessToken: accessToken ?? this.accessToken,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSuccessfulConnectionAt:
          lastSuccessfulConnectionAt ?? this.lastSuccessfulConnectionAt,
      serverVersion: serverVersion ?? this.serverVersion,
    );
  }
}

class PairServerInput {
  const PairServerInput({
    required this.host,
    required this.port,
    required this.pairingCode,
    this.clientName = 'Codex Dev Flutter',
  });

  final String host;
  final int port;
  final String pairingCode;
  final String clientName;

  String get serverUrl {
    final trimmed = host.trim();
    final parsed =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? Uri.parse(trimmed)
        : Uri(scheme: 'http', host: trimmed);
    final path = parsed.path == '/' ? '' : parsed.path;
    final normalized = Uri(
      scheme: parsed.scheme,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : port,
      path: path,
    );
    return normalized.toString().replaceFirst(RegExp(r'/$'), '');
  }
}

enum PairingFailureKind {
  validation,
  unreachable,
  rejected,
  expired,
  incompatible,
  malformed,
}

class PairingFailure {
  const PairingFailure(this.kind, this.message);

  final PairingFailureKind kind;
  final String message;
}
