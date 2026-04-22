import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isCompact => screenWidth < AppBreakpoints.tablet;
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), action: action, duration: duration),
      );
  }
}
