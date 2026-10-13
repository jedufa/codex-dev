import 'package:flutter/material.dart';
import 'app/codex_dev_app.dart';
import 'services/mock_codex_api_client.dart';

// The only entry point uses an inert, in-process implementation.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the accessible UI tree available throughout this interactive demo.
  WidgetsBinding.instance.ensureSemantics();
  runApp(CodexDevApp(apiClient: MockCodexApiClient()));
}
