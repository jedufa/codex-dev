import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.drawer,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      extendBody: true,
      drawer: drawer,
      drawerEdgeDragWidth: 64,
      bottomNavigationBar: bottomNavigationBar,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.pageTop, colors.pageBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
