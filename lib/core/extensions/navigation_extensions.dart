import 'package:flutter/material.dart';

extension NavigationX on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  Future<T?> pushPage<T>(Widget page) {
    return navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  Future<T?> pushReplacementPage<T, TO>(Widget page, {TO? result}) {
    return navigator.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  void popPage<T extends Object?>([T? result]) {
    if (navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }
}
