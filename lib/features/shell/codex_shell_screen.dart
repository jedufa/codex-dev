import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../activity/activity_controller.dart';
import '../activity/activity_screen.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_screen.dart';
import '../connection/connection_controller.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../workspace/workspace_controller.dart';
import '../workspace/workspace_screen.dart';
import 'shell_controller.dart';

class CodexShellScreen extends StatelessWidget {
  const CodexShellScreen({
    super.key,
    required this.shellController,
    required this.chatController,
    required this.workspaceController,
    required this.activityController,
    required this.settingsController,
    required this.connectionController,
    required this.onPaired,
  });

  final ShellController shellController;
  final ChatController chatController;
  final WorkspaceController workspaceController;
  final ActivityController activityController;
  final SettingsController settingsController;
  final ConnectionController connectionController;
  final Future<void> Function() onPaired;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        shellController,
        chatController,
        workspaceController,
        activityController,
        settingsController,
        connectionController,
      ]),
      builder: (context, _) {
        return AppScaffold(
          drawer: _RouteDrawer(
            selected: shellController.selectedRoute,
            onSelected: shellController.selectRoute,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: const Text(
                    'SIMULATED DEMO · NO LIVE CODEX CONNECTION',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                _Header(
                  route: shellController.selectedRoute,
                  onSettingsSelected: () =>
                      shellController.selectRoute(AppRoute.settings),
                ),
                Expanded(
                  child: IndexedStack(
                    index: AppRoute.values.indexOf(
                      shellController.selectedRoute,
                    ),
                    children: [
                      ChatScreen(
                        controller: chatController,
                        connectionController: connectionController,
                        onPaired: onPaired,
                      ),
                      WorkspaceScreen(
                        controller: workspaceController,
                        isPaired: connectionController.isPaired,
                      ),
                      ActivityScreen(
                        controller: activityController,
                        isPaired: connectionController.isPaired,
                      ),
                      SettingsScreen(
                        controller: settingsController,
                        connectionController: connectionController,
                        onPaired: onPaired,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.route, required this.onSettingsSelected});

  final AppRoute route;
  final VoidCallback onSettingsSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Row(
        children: [
          const _RouteMenuButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colors.floatingSurface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Color(0x22000000),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: colors.selectedSegment,
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      route == AppRoute.chat
                          ? 'Codex Dev'
                          : 'Codex Dev / ${route.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundIcon(
            icon: Icons.settings_rounded,
            tooltip: 'Demo settings',
            onPressed: onSettingsSelected,
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColors.floatingSurface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x22000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: scheme.primary, size: 21),
            tooltip: tooltip,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _RouteMenuButton extends StatelessWidget {
  const _RouteMenuButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.floatingSurface,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x22000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          key: const Key('open-navigation-drawer'),
          tooltip: 'Open navigation',
          icon: Icon(Icons.menu_rounded, color: scheme.primary, size: 21),
          padding: EdgeInsets.zero,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }
}

class _RouteDrawer extends StatelessWidget {
  const _RouteDrawer({required this.selected, required this.onSelected});

  final AppRoute selected;
  final ValueChanged<AppRoute> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Drawer(
      key: const Key('navigation-drawer'),
      backgroundColor: colors.floatingSurface,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: colors.selectedSegment,
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Codex Dev',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: scheme.outline.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 6),
            for (final route in AppRoute.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  key: Key('navigation-drawer-${route.name}'),
                  selected: selected == route,
                  selectedTileColor: colors.selectedSegment,
                  selectedColor: scheme.primary,
                  iconColor: selected == route
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.72),
                  textColor: selected == route
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.88),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  dense: true,
                  leading: Icon(_routeIcon(route), size: 21),
                  title: Text(
                    route.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(route);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

IconData _routeIcon(AppRoute route) {
  switch (route) {
    case AppRoute.chat:
      return Icons.forum_rounded;
    case AppRoute.workspace:
      return Icons.folder_copy_rounded;
    case AppRoute.activity:
      return Icons.bolt_rounded;
    case AppRoute.settings:
      return Icons.tune_rounded;
  }
}
