import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/key_value_storage.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/errors/result.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
const _appRole = 'seller';

final class AuthState {
  const AuthState({
    required this.onboardingCompleted,
    required this.isAuthenticated,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.rememberMe,
    required this.pendingResetEmail,
    required this.otpRequestedAt,
    required this.otpVerified,
    required this.verifiedResetOtp,
  });

  factory AuthState.initial(KeyValueStorage storage) {
    return AuthState(
      onboardingCompleted:
          storage.readBool(_AuthStorageKeys.onboarding) ?? false,
      isAuthenticated:
          storage.readBool(_AuthStorageKeys.isAuthenticated) ?? false,
      fullName: storage.readString(_AuthStorageKeys.fullName) ?? 'Book Lover',
      email:
          storage.readString(_AuthStorageKeys.email) ?? 'buyer@bookswheels.com',
      phone: storage.readString(_AuthStorageKeys.phone) ?? '+8801712345678',
      password: storage.readString(_AuthStorageKeys.password) ?? 'Password@123',
      accessToken: storage.readString(_AuthStorageKeys.accessToken),
      refreshToken: storage.readString(_AuthStorageKeys.refreshToken),
      userId: storage.readString(_AuthStorageKeys.userId),
      role: storage.readString(_AuthStorageKeys.role),
      rememberMe: storage.readBool(_AuthStorageKeys.rememberMe) ?? false,
      pendingResetEmail: storage.readString(_AuthStorageKeys.pendingResetEmail),
      otpRequestedAt: _parseDateTime(
        storage.readString(_AuthStorageKeys.otpRequestedAt),
      ),
      otpVerified: storage.readBool(_AuthStorageKeys.otpVerified) ?? false,
      verifiedResetOtp: storage.readString(_AuthStorageKeys.verifiedResetOtp),
    );
  }

  final bool onboardingCompleted;
  final bool isAuthenticated;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? role;
  final bool rememberMe;
  final String? pendingResetEmail;
  final DateTime? otpRequestedAt;
  final bool otpVerified;
  final String? verifiedResetOtp;

  bool get hasPendingOtp => pendingResetEmail != null && otpRequestedAt != null;

  int get secondsUntilResend {
    if (otpRequestedAt == null) {
      return 0;
    }

    final remaining = 45 - DateTime.now().difference(otpRequestedAt!).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  AuthState copyWith({
    bool? onboardingCompleted,
    bool? isAuthenticated,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? role,
    bool? rememberMe,
    String? pendingResetEmail,
    DateTime? otpRequestedAt,
    bool? otpVerified,
    String? verifiedResetOtp,
    bool clearPendingResetEmail = false,
    bool clearOtpRequestedAt = false,
    bool clearVerifiedResetOtp = false,
  }) {
    return AuthState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      rememberMe: rememberMe ?? this.rememberMe,
      pendingResetEmail: clearPendingResetEmail
          ? null
          : pendingResetEmail ?? this.pendingResetEmail,
      otpRequestedAt: clearOtpRequestedAt
          ? null
          : otpRequestedAt ?? this.otpRequestedAt,
      otpVerified: otpVerified ?? this.otpVerified,
      verifiedResetOtp: clearVerifiedResetOtp
          ? null
          : verifiedResetOtp ?? this.verifiedResetOtp,
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

final class AuthController extends Notifier<AuthState> {
  late final KeyValueStorage _storage;

  @override
  AuthState build() {
    _storage = ref.watch(keyValueStorageProvider);
    final initial = AuthState.initial(_storage);
    _log('init', initial);
    return initial;
  }

  Future<void> completeOnboarding() async {
    _logStep('completeOnboarding:start');
    state = state.copyWith(onboardingCompleted: true);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
    _log('completeOnboarding:done', state);
  }

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _logStep('signIn:start email=${email.trim().toLowerCase()}');
    final normalizedEmail = email.trim().toLowerCase();
    final result = await ref
        .read(apiClientProvider)
        .post<Map<String, dynamic>>(
          '/auth/login',
          data: {'email': normalizedEmail, 'password': password},
          parser: _extractDataMap,
        );

    final data = _unwrap(result);
    final accessToken = (data['accessToken'] ?? '').toString();
    final refreshToken = (data['refreshToken'] ?? '').toString();
    final user = data['user'];
    final userMap = user is Map<String, dynamic>
        ? user
        : <String, dynamic>{};
    final name = (userMap['name'] ?? state.fullName).toString();
    final role = (data['role'] ?? userMap['role'] ?? '').toString();
    final userId = (data['_id'] ?? userMap['_id'] ?? '').toString();

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      _logStep('signIn:error missing tokens in response');
      throw const AuthFlowException(
        'Authentication failed. Please try again.',
      );
    }

    state = state.copyWith(
      isAuthenticated: true,
      rememberMe: rememberMe,
      onboardingCompleted: true,
      email: normalizedEmail,
      fullName: name,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId.isEmpty ? null : userId,
      role: role.isEmpty ? null : role,
    );

    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, true);
    await _storage.writeBool(_AuthStorageKeys.rememberMe, rememberMe);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
    await _storage.writeString(_AuthStorageKeys.email, normalizedEmail);
    await _storage.writeString(_AuthStorageKeys.fullName, name);
    await _storage.writeString(_AuthStorageKeys.accessToken, accessToken);
    await _storage.writeString(_AuthStorageKeys.refreshToken, refreshToken);
    if (userId.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.userId, userId);
    }
    if (role.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.role, role);
    }
    _log('signIn:done', state);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _logStep('signUp:start email=${email.trim().toLowerCase()}');
    final normalizedEmail = email.trim().toLowerCase();
    final payload = {
      'name': fullName.trim(),
      'email': normalizedEmail,
      'password': password,
      'confirmPassword': password,
      'role': _appRole,
    };

    final result = await ref
        .read(apiClientProvider)
        .post<Map<String, dynamic>>(
          '/auth/register',
          data: payload,
          parser: _extractDataMap,
        );
    final data = _unwrap(result);
    final accessToken = (data['accessToken'] ?? '').toString();
    final refreshToken = (data['refreshToken'] ?? '').toString();
    final userId = (data['_id'] ?? '').toString();
    final role = (data['role'] ?? _appRole).toString();

    state = state.copyWith(
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      password: password,
      rememberMe: true,
      isAuthenticated: true,
      onboardingCompleted: true,
      accessToken: accessToken.isEmpty ? null : accessToken,
      refreshToken: refreshToken.isEmpty ? null : refreshToken,
      userId: userId.isEmpty ? null : userId,
      role: role.isEmpty ? null : role,
    );

    await _storage.writeString(_AuthStorageKeys.fullName, state.fullName);
    await _storage.writeString(_AuthStorageKeys.email, state.email);
    await _storage.writeString(_AuthStorageKeys.phone, state.phone);
    await _storage.writeString(_AuthStorageKeys.password, state.password);
    if (accessToken.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.accessToken, accessToken);
    }
    if (refreshToken.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.refreshToken, refreshToken);
    }
    if (userId.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.userId, userId);
    }
    if (role.isNotEmpty) {
      await _storage.writeString(_AuthStorageKeys.role, role);
    }
    await _storage.writeBool(_AuthStorageKeys.rememberMe, true);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, true);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
    _log('signUp:done', state);
  }

  Future<void> requestOtp(String email) async {
    _logStep('requestOtp:start email=${email.trim().toLowerCase()}');
    final normalizedEmail = email.trim().toLowerCase();
    final result = await ref
        .read(apiClientProvider)
        .post<Map<String, dynamic>>(
          '/auth/forgot-password',
          data: {'email': normalizedEmail},
          parser: _extractDataMap,
        );
    _unwrap(result);

    final now = DateTime.now();

    state = state.copyWith(
      pendingResetEmail: normalizedEmail,
      otpRequestedAt: now,
      otpVerified: false,
      clearVerifiedResetOtp: true,
    );

    await _storage.writeString(
      _AuthStorageKeys.pendingResetEmail,
      normalizedEmail,
    );
    await _storage.writeString(
      _AuthStorageKeys.otpRequestedAt,
      now.toIso8601String(),
    );
    await _storage.writeBool(_AuthStorageKeys.otpVerified, false);
    await _storage.remove(_AuthStorageKeys.verifiedResetOtp);
    _log('requestOtp:done', state);
  }

  Future<void> resendOtp() async {
    _logStep('resendOtp:start');
    if (state.pendingResetEmail == null) {
      _logStep('resendOtp:error no pending email');
      throw const AuthFlowException('Start the password reset flow again.');
    }

    if (state.secondsUntilResend > 0) {
      _logStep('resendOtp:error wait=${state.secondsUntilResend}s');
      throw AuthFlowException(
        'Resend available in ${state.secondsUntilResend}s.',
      );
    }

    await requestOtp(state.pendingResetEmail!);
    _log('resendOtp:done', state);
  }

  Future<void> verifyOtp(String otp) async {
    _logStep('verifyOtp:start otpLength=${otp.trim().length}');
    if (!state.hasPendingOtp) {
      _logStep('verifyOtp:error no pending otp context');
      throw const AuthFlowException('Start the password reset flow again.');
    }

    final enteredOtp = otp.trim();
    final result = await ref
        .read(apiClientProvider)
        .post<Map<String, dynamic>>(
          '/auth/verify-otp',
          data: {'email': state.pendingResetEmail, 'otp': enteredOtp},
          parser: _extractDataMap,
        );
    _unwrap(result);

    state = state.copyWith(otpVerified: true, verifiedResetOtp: enteredOtp);
    await _storage.writeBool(_AuthStorageKeys.otpVerified, true);
    await _storage.writeString(_AuthStorageKeys.verifiedResetOtp, enteredOtp);
    _log('verifyOtp:done', state);
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    _logStep('resetPassword:start');
    if (!state.otpVerified ||
        state.pendingResetEmail == null ||
        state.verifiedResetOtp == null) {
      _logStep('resetPassword:error otp not verified');
      throw const AuthFlowException(
        'Verify the OTP before resetting password.',
      );
    }

    if (newPassword != confirmPassword) {
      _logStep('resetPassword:error password mismatch');
      throw const AuthFlowException('Passwords do not match.');
    }

    final result = await ref
        .read(apiClientProvider)
        .post<Map<String, dynamic>>(
          '/auth/reset-password',
          data: {
            'email': state.pendingResetEmail,
            'otp': state.verifiedResetOtp,
            'password': newPassword,
          },
          parser: _extractDataMap,
        );
    _unwrap(result);

    state = state.copyWith(
      password: newPassword,
      isAuthenticated: false,
      otpVerified: false,
      clearPendingResetEmail: true,
      clearOtpRequestedAt: true,
      clearVerifiedResetOtp: true,
      accessToken: null,
      refreshToken: null,
    );

    await _storage.writeString(_AuthStorageKeys.password, newPassword);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
    await _storage.writeBool(_AuthStorageKeys.otpVerified, false);
    await _storage.remove(_AuthStorageKeys.pendingResetEmail);
    await _storage.remove(_AuthStorageKeys.otpRequestedAt);
    await _storage.remove(_AuthStorageKeys.verifiedResetOtp);
    await _storage.remove(_AuthStorageKeys.accessToken);
    await _storage.remove(_AuthStorageKeys.refreshToken);
    _log('resetPassword:done', state);
  }

  Future<void> logout() async {
    _logStep('logout:start');
    if (state.accessToken != null && state.accessToken!.isNotEmpty) {
      await ref.read(apiClientProvider).post<dynamic>(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${state.accessToken!}'},
        ),
      );
    }
    state = state.copyWith(
      isAuthenticated: false,
      accessToken: null,
      refreshToken: null,
      userId: null,
      role: null,
    );
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
    await _storage.remove(_AuthStorageKeys.accessToken);
    await _storage.remove(_AuthStorageKeys.refreshToken);
    await _storage.remove(_AuthStorageKeys.userId);
    await _storage.remove(_AuthStorageKeys.role);
    _log('logout:done', state);
  }

  Future<void> updateProfileBasics({
    required String fullName,
    String? phone,
  }) async {
    state = state.copyWith(
      fullName: fullName.trim().isEmpty ? state.fullName : fullName.trim(),
      phone: phone == null ? state.phone : phone.trim(),
    );
    await _storage.writeString(_AuthStorageKeys.fullName, state.fullName);
    await _storage.writeString(_AuthStorageKeys.phone, state.phone);
    _log('updateProfileBasics:done', state);
  }

  void _logStep(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[AUTH] $message\n');
  }

  void _log(String label, AuthState current) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[AUTH][STATE][$label] ${_snapshot(current)}\n');
  }

  String _snapshot(AuthState s) {
    return '{isAuthenticated:${s.isAuthenticated}, onboardingCompleted:${s.onboardingCompleted}, email:${s.email}, fullName:${s.fullName}, userId:${s.userId}, role:${s.role}, hasAccessToken:${(s.accessToken ?? '').isNotEmpty}, hasRefreshToken:${(s.refreshToken ?? '').isNotEmpty}, rememberMe:${s.rememberMe}, pendingResetEmail:${s.pendingResetEmail}, otpRequestedAt:${s.otpRequestedAt}, otpVerified:${s.otpVerified}, hasVerifiedResetOtp:${(s.verifiedResetOtp ?? '').isNotEmpty}}';
  }
}

Map<String, dynamic> _extractDataMap(dynamic raw) {
  if (raw is! Map<String, dynamic>) {
    throw const AuthFlowException('Unexpected server response.');
  }

  if (raw['success'] == false) {
    final message =
        (raw['message'] ?? 'Request could not be completed.').toString();
    throw AuthFlowException(message);
  }

  final data = raw['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _unwrap(Result<Map<String, dynamic>> result) {
  return switch (result) {
    Success(data: final data) => data,
    ResultFailure(error: final error) => throw AuthFlowException(
      error.message,
    ),
  };
}

final class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class _AuthStorageKeys {
  const _AuthStorageKeys._();

  static const onboarding = 'buyer_onboarding_completed';
  static const isAuthenticated = 'buyer_is_authenticated';
  static const fullName = 'buyer_full_name';
  static const email = 'buyer_email';
  static const phone = 'buyer_phone';
  static const password = 'buyer_password';
  static const accessToken = 'buyer_access_token';
  static const refreshToken = 'buyer_refresh_token';
  static const userId = 'buyer_user_id';
  static const role = 'buyer_role';
  static const rememberMe = 'buyer_remember_me';
  static const pendingResetEmail = 'buyer_pending_reset_email';
  static const otpRequestedAt = 'buyer_otp_requested_at';
  static const otpVerified = 'buyer_otp_verified';
  static const verifiedResetOtp = 'buyer_verified_reset_otp';
}
