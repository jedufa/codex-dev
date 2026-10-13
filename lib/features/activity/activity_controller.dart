import 'package:flutter/foundation.dart';

import '../../services/codex_api_client.dart';
import 'activity_models.dart';

class ActivityController extends ChangeNotifier {
  ActivityController({required this.apiClient});

  final CodexApiClient apiClient;
  List<ActivityItem> items = const [];
  bool loading = false;

  void record(
    String title,
    String detail, {
    ActivityLevel level = ActivityLevel.info,
  }) {
    final item = ActivityItem(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      detail: detail,
      level: level,
      createdAt: DateTime.now(),
    );
    items = [item, ...items].take(40).toList(growable: false);
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final serverItems = await apiClient.getActivity();
      items = [...items, ...serverItems].take(40).toList(growable: false);
    } catch (error) {
      record(
        'Activity unavailable',
        'Server activity could not be loaded.',
        level: ActivityLevel.warning,
      );
    }
    loading = false;
    notifyListeners();
  }
}
