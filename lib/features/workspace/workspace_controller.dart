import 'package:flutter/foundation.dart';

import '../../services/codex_api_client.dart';
import 'workspace_models.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController({required this.apiClient});

  final CodexApiClient apiClient;
  WorkspaceStatus? status;
  bool loading = false;
  String? errorMessage;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      status = await apiClient.getWorkspaceStatus();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    loading = false;
    notifyListeners();
  }
}
