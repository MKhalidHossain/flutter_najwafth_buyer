import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_breakpoints.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.horizontalPadding = 20,
    this.maxWidth = 540,
    this.scrollable = true,
  });

  final Widget child;
  final double horizontalPadding;
  final double maxWidth;
  final bool scrollable;

  static const backgroundColor = Color(0xFFF8F1E8);

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: _AuthScaffoldBody(),
    );
  }
}

class _AuthScaffoldBody extends StatelessWidget {
  const _AuthScaffoldBody();

  @override
  Widget build(BuildContext context) {
    final scaffold = context.findAncestorWidgetOfExactType<AuthScaffold>()!;
    final canPop = Navigator.of(context).canPop();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < AppBreakpoints.mobile
        ? scaffold.horizontalPadding
        : scaffold.horizontalPadding + 4;
    final contentWidth = screenWidth >= AppBreakpoints.tablet
        ? scaffold.maxWidth
        : double.infinity;
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canPop) ...[
              const _AuthBackButton(),
              const SizedBox(height: 8),
            ],
            scaffold.child,
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AuthScaffold.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: scaffold.scrollable
              ? SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: content,
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: content,
                ),
        ),
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.82),
          foregroundColor: const Color(0xFF23252B),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
    );
  }
}
