import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings_controller.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'theme/keyboard_focus_ring_theme.dart';
import 'theme/theme_mode_provider.dart';

class PacimInvoicerApp extends ConsumerWidget {
  const PacimInvoicerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loading the settings applies the saved appearance to themeModeProvider.
    ref.watch(
      settingsControllerProvider.select((settings) => settings.hasValue),
    );
    final platform = defaultTargetPlatform;
    return MaterialApp.router(
      title: 'Pacim Invoicer',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: buildAppTheme(brightness: Brightness.light, platform: platform),
      darkTheme: buildAppTheme(brightness: Brightness.dark, platform: platform),
      builder: (context, child) => KeyboardFocusRingTheme(child: child!),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
