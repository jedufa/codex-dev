class ServerStatusDto {
  const ServerStatusDto({
    required this.connected,
    required this.serverUrl,
    required this.version,
    required this.health,
  });

  final bool connected;
  final String serverUrl;
  final String version;
  final String health;
}
