

import 'app_failure.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      ResultFailure<T>(:final error) => failure(error),
    };
  }

  T? get dataOrNull {
    return switch (this) {
      Success<T>(:final data) => data,
      ResultFailure<T>() => null,
    };
  }

  AppFailure? get failureOrNull {
    return switch (this) {
      Success<T>() => null,
      ResultFailure<T>(:final error) => error,
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.error);

  final AppFailure error;
}
