import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/theme/app_theme.dart';
import 'package:kmail_desktop/features/shell/presentation/app_shell.dart';

class KmailApp extends ConsumerWidget {
  const KmailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = AppTheme(settings: settings);
    return MaterialApp(
      title: 'Kmail',
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: settings.themeMode,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppShell(),
    );
  }
}
