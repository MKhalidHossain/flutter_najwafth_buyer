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

  factory AppConfig.development() => AppConfig(
    appName: 'Najwafth Buyer',
    environment: AppEnvironment.development,
    baseUrl: _defaultDevBaseUrl(),
  );

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
    return 'http://localhost:5002/api/v1';
  }

  return switch (defaultTargetPlatform) {
    // 10.0.2.2 = host machine's localhost as seen from the Android emulator.
    // For a physical Android device on the same Wi-Fi, use the Mac's LAN IP
    // instead (currently 10.10.26.113).
    TargetPlatform.android => 'http://10.0.2.2:5002/api/v1',
    _ => 'http://localhost:5002/api/v1',
  };
}
