import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
import 'app_breakpoints.dart';
import 'navigation_sidebar.dart';
import 'status_bar.dart';
import 'window_title_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final usesDrawer = width < AppBreakpoints.compactMaxWidth;
    final usesRail = !usesDrawer && width < AppBreakpoints.mediumMaxWidth;
    final showsTitleBar =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final tokens = Theme.of(context).extension<AppColorTokens>()!;

    return Scaffold(
      backgroundColor: tokens.surface,
      drawer: usesDrawer
          ? Builder(
              builder: (context) => Drawer(
                width: NavigationSidebar.fullWidth,
                child: NavigationSidebar(
                  isRail: false,
                  onDestinationSelected: () => Navigator.of(context).pop(),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          if (showsTitleBar) const WindowTitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!usesDrawer) NavigationSidebar(isRail: usesRail),
                Expanded(
                  child: Column(
                    children: [
                      if (usesDrawer) const _DrawerButtonBar(),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const StatusBar(),
        ],
      ),
    );
  }
}

class _DrawerButtonBar extends StatelessWidget {
  const _DrawerButtonBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Open navigation',
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }
}
