import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/network_providers.dart';
import '../core/providers/theme_mode_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_routes.dart';
import '../features/auth/presentation/pages/enter_otp_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../core/widgets/splash/presentation/splash_page.dart';

final class NajwafthBuyerApp extends ConsumerWidget {
  const NajwafthBuyerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.isDevelopment,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeControllerProvider),
      initialRoute: AuthRoutes.splash,
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          AuthRoutes.splash => const SplashPage(),
          AuthRoutes.onboarding => const OnboardingPage(),
          AuthRoutes.signIn => const SignInPage(),
          AuthRoutes.signUp => const SignUpPage(),
          AuthRoutes.forgotPassword => const ForgotPasswordPage(),
          AuthRoutes.enterOtp => const EnterOtpPage(),
          AuthRoutes.resetPassword => const ResetPasswordPage(),
          AuthRoutes.home => const HomePage(),
          _ => const SplashPage(),
        };

        return MaterialPageRoute<void>(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}
