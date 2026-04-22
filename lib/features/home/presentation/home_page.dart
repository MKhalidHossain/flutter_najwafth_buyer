import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/auth_routes.dart';
import '../../auth/presentation/widgets/auth_scaffold.dart';
import '../../auth/presentation/widgets/auth_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandHeader(topSpacing: 32, bottomSpacing: 18, logoWidth: 210),
          Text(
            'Welcome back, ${authState.fullName}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF23252B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your buyer app auth flow is now connected and responsive. This page acts as the signed-in destination until the catalog/dashboard is implemented.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF6E6E6E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          const AuthSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeatureRow(
                  icon: Icons.menu_book_outlined,
                  title: 'Browse books',
                  description: 'Ready for your product listing module.',
                ),
                SizedBox(height: 18),
                _FeatureRow(
                  icon: Icons.local_shipping_outlined,
                  title: 'Track delivery',
                  description: 'Matches the onboarding promise and next flow.',
                ),
                SizedBox(height: 18),
                _FeatureRow(
                  icon: Icons.security_outlined,
                  title: 'Persisted auth state',
                  description: 'Onboarding and sign-in survive app restarts.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Image.asset(
              'assets/images/onboarding/onboarding_orders.png',
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 26),
          AuthPrimaryButton(
            label: 'Sign out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AuthRoutes.signIn, (route) => false);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE0ECF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF5D8FBE)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF23252B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6E6E6E),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
