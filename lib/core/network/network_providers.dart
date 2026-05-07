import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../config/app_config.dart';
import '../storage/storage_providers.dart';
import 'api_client.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.development();
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(keyValueStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: const {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = storage.readString('buyer_access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          _printLine(
            '[API][REQ] ${options.method} ${options.baseUrl}${options.path}',
          );
          _printLine('[API][REQ][HEADERS] ${options.headers}');
          _printLine('[API][REQ][QUERY] ${options.queryParameters}');
          _printLine('[API][REQ][BODY]\n${_readable(options.data)}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          _printLine(
            '[API][RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
          );
          _printLine('[API][RES][BODY]\n${_readable(response.data)}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          _printLine(
            '[API][ERR] ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.path}',
          );
          _printLine('[API][ERR][MESSAGE] ${error.message}');
          _printLine('[API][ERR][BODY]\n${_readable(error.response?.data)}');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

void _printLine(String message) {
  debugPrint('$message\n');
}

String _readable(dynamic value) {
  if (value == null) {
    return 'null';
  }

  if (value is FormData) {
    final fields = value.fields.map((e) => '${e.key}: ${e.value}').toList();
    final files = value.files
        .map((e) => '${e.key}: ${e.value.filename ?? 'file'}')
        .toList();
    return 'FormData{\n  fields: $fields,\n  files: $files\n}';
  }

  if (value is Map || value is List) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  return value.toString();
}
