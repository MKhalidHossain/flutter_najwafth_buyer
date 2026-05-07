import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

final class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
  });

  factory AppConfig.development() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    final baseUrl = configuredBaseUrl.isNotEmpty
        ? configuredBaseUrl
        : _defaultDevBaseUrl();

    return AppConfig(
      appName: 'Books on wheels',
      environment: AppEnvironment.development,
      baseUrl: baseUrl,
    );
  }

  final String appName;
  final AppEnvironment environment;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;
}

String _defaultDevBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:5001/api/v1';
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'http://10.0.2.2:5001/api/v1',
    _ => 'http://localhost:5001/api/v1',
  };
}
