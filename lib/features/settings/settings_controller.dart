import 'package:flutter/foundation.dart';

import '../../core/errors/error_mapper.dart';
import '../../services/codex_api_client.dart';
import 'settings_models.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({required this.apiClient});

  final CodexApiClient apiClient;
  SettingsStatus? status;
  DeploymentValidationResult? deploymentValidation;
  bool loading = false;
  bool validatingDeployment = false;
  String? errorMessage;
  String? deploymentValidationError;
  bool connectionUnauthorized = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      status = await apiClient.getSettingsStatus();
      errorMessage = null;
      connectionUnauthorized = false;
    } catch (error) {
      errorMessage = ErrorMapper.fromObject(error).message;
      final lower = errorMessage!.toLowerCase();
      connectionUnauthorized =
          lower.contains('pairing expired') ||
          lower.contains('revoked') ||
          lower.contains('reconnect') ||
          lower.contains('401');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> validateDeployment(DeploymentValidationInput input) async {
    validatingDeployment = true;
    deploymentValidationError = null;
    notifyListeners();
    try {
      deploymentValidation = await apiClient.validateDeployment(input);
    } catch (error) {
      deploymentValidationError = ErrorMapper.fromObject(error).message;
    }
    validatingDeployment = false;
    notifyListeners();
  }
}
