import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';
import 'app_error_view.dart';
import 'app_loading.dart';

final class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? loading;
  final Widget Function(AppFailure failure)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const AppLoading(),
      error: (rawError, stackTrace) {
        final failure = AppFailure.fromObject(rawError, stackTrace);
        return error?.call(failure) ??
            AppErrorView.fromFailure(failure, onRetry: onRetry);
      },
    );
  }
}
