
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';

extension AsyncValueFailureX<T> on AsyncValue<T> {
  AppFailure? get failureOrNull {
    return whenOrNull(
      error: (error, stackTrace) => AppFailure.fromObject(error, stackTrace),
    );
  }
}
