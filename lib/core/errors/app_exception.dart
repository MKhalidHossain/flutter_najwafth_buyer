final class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause, this.stackTrace});

  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final label = code == null ? 'AppException' : 'AppException($code)';
    return '$label: $message';
  }
}
