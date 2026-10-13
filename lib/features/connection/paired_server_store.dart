import 'connection_models.dart';

abstract class PairedServerStore {
  Future<PairedServerConnection?> load();
  Future<void> save(PairedServerConnection connection);
  Future<void> clear();
}

class MemoryPairedServerStore implements PairedServerStore {
  MemoryPairedServerStore([this._connection]);

  PairedServerConnection? _connection;

  @override
  Future<PairedServerConnection?> load() async => _connection;

  @override
  Future<void> save(PairedServerConnection connection) async {
    _connection = connection;
  }

  @override
  Future<void> clear() async {
    _connection = null;
  }
}

PairedServerConnection demoConnection() => PairedServerConnection(
  serverUrl: 'In-process simulation',
  accessToken: 'inert-demo-marker',
  pairedAt: DateTime.utc(2026, 10, 13),
  serverVersion: 'simulated 0.1.0',
);
