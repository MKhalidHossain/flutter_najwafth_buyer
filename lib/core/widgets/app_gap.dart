import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

final class AppGap extends StatelessWidget {
  const AppGap(this.size, {super.key});

  const AppGap.xs({super.key}) : size = AppSpacing.xs;
  const AppGap.sm({super.key}) : size = AppSpacing.sm;
  const AppGap.md({super.key}) : size = AppSpacing.md;
  const AppGap.lg({super.key}) : size = AppSpacing.lg;
  const AppGap.xl({super.key}) : size = AppSpacing.xl;

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size);
  }
}
