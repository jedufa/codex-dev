import 'package:flutter/foundation.dart';

import '../../app/app_routes.dart';

class ShellController extends ChangeNotifier {
  AppRoute selectedRoute = AppRoute.chat;

  void selectRoute(AppRoute route) {
    if (selectedRoute == route) return;
    selectedRoute = route;
    notifyListeners();
  }
}
