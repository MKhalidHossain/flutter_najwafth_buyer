import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/network_providers.dart';
import '../core/providers/theme_mode_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/splash/presentation/splash_page.dart';

final class NajwafthDriverApp extends ConsumerWidget {
  const NajwafthDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.isDevelopment,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider),
      home: const SplashPage(),
    );
  }
}
