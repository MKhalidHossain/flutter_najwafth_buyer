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
        child: scaffold.child,
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
