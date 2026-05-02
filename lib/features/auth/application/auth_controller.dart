import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/key_value_storage.dart';
import '../../../core/storage/storage_providers.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final class AuthState {
  const AuthState({
    required this.onboardingCompleted,
    required this.isAuthenticated,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.rememberMe,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.pendingResetEmail,
    required this.otpRequestedAt,
    required this.otpVerified,
    required this.resetToken,
  });

  factory AuthState.initial(KeyValueStorage storage) {
    return AuthState(
      onboardingCompleted:
          storage.readBool(_AuthStorageKeys.onboarding) ?? false,
      isAuthenticated:
          storage.readBool(_AuthStorageKeys.isAuthenticated) ?? false,
      fullName: storage.readString(_AuthStorageKeys.fullName) ?? '',
      email: storage.readString(_AuthStorageKeys.email) ?? '',
      phone: storage.readString(_AuthStorageKeys.phone) ?? '',
      rememberMe: storage.readBool(_AuthStorageKeys.rememberMe) ?? false,
      accessToken: storage.readString(_AuthStorageKeys.accessToken),
      refreshToken: storage.readString(_AuthStorageKeys.refreshToken),
      userId: storage.readString(_AuthStorageKeys.userId),
      role: storage.readString(_AuthStorageKeys.role),
      pendingResetEmail: storage.readString(_AuthStorageKeys.pendingResetEmail),
      otpRequestedAt: _parseDateTime(
        storage.readString(_AuthStorageKeys.otpRequestedAt),
      ),
      otpVerified: storage.readBool(_AuthStorageKeys.otpVerified) ?? false,
      resetToken: storage.readString(_AuthStorageKeys.resetToken),
    );
  }

  final bool onboardingCompleted;
  final bool isAuthenticated;
  final String fullName;
  final String email;
  final String phone;
  final bool rememberMe;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? role;
  final String? pendingResetEmail;
  final DateTime? otpRequestedAt;
  final bool otpVerified;
  final String? resetToken;

  bool get hasPendingOtp =>
      pendingResetEmail != null && otpRequestedAt != null;

  int get secondsUntilResend {
    if (otpRequestedAt == null) {
      return 0;
    }
    final remaining =
        60 - DateTime.now().difference(otpRequestedAt!).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  AuthState copyWith({
    bool? onboardingCompleted,
    bool? isAuthenticated,
    String? fullName,
    String? email,
    String? phone,
    bool? rememberMe,
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? role,
    String? pendingResetEmail,
    DateTime? otpRequestedAt,
    bool? otpVerified,
    String? resetToken,
    bool clearPendingResetEmail = false,
    bool clearOtpRequestedAt = false,
    bool clearResetToken = false,
    bool clearTokens = false,
  }) {
    return AuthState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rememberMe: rememberMe ?? this.rememberMe,
      accessToken: clearTokens ? null : accessToken ?? this.accessToken,
      refreshToken: clearTokens ? null : refreshToken ?? this.refreshToken,
      userId: clearTokens ? null : userId ?? this.userId,
      role: clearTokens ? null : role ?? this.role,
      pendingResetEmail: clearPendingResetEmail
          ? null
          : pendingResetEmail ?? this.pendingResetEmail,
      otpRequestedAt: clearOtpRequestedAt
          ? null
          : otpRequestedAt ?? this.otpRequestedAt,
      otpVerified: otpVerified ?? this.otpVerified,
      resetToken: clearResetToken ? null : resetToken ?? this.resetToken,
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
  late final ApiClient _apiClient;

  @override
  AuthState build() {
    _storage = ref.watch(keyValueStorageProvider);
    _apiClient = ref.watch(apiClientProvider);
    return AuthState.initial(_storage);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
  }

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
      parser: (data) =>
          (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );

    switch (result) {
      case Success(:final data):
        final user = data['user'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        state = state.copyWith(
          isAuthenticated: true,
          rememberMe: rememberMe,
          onboardingCompleted: true,
          fullName: user['fullName'] as String? ?? '',
          email: user['email'] as String? ?? email.trim().toLowerCase(),
          phone: user['phone'] as String? ?? '',
          userId: user['_id']?.toString(),
          role: user['role'] as String?,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        await _persistSession(rememberMe: rememberMe);

      case ResultFailure(:final error):
        throw AuthFlowException(error.message);
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
        'role': 'buyer',
      },
      parser: (data) =>
          (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );

    switch (result) {
      case Success(:final data):
        final user = data['user'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        state = state.copyWith(
          fullName: user['fullName'] as String? ?? fullName.trim(),
          email: user['email'] as String? ?? email.trim().toLowerCase(),
          phone: user['phone'] as String? ?? phone.trim(),
          userId: user['_id']?.toString(),
          role: user['role'] as String?,
          accessToken: accessToken,
          refreshToken: refreshToken,
          rememberMe: true,
          isAuthenticated: true,
          onboardingCompleted: true,
        );

        await _persistSession(rememberMe: true);

      case ResultFailure(:final error):
        throw AuthFlowException(error.message);
    }
  }

  Future<void> requestOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final now = DateTime.now();

    final result = await _apiClient.post<dynamic>(
      '/auth/forgot-password',
      data: {'email': normalizedEmail},
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          pendingResetEmail: normalizedEmail,
          otpRequestedAt: now,
          otpVerified: false,
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

      case ResultFailure(:final error):
        throw AuthFlowException(error.message);
    }
  }

  Future<void> resendOtp() async {
    if (state.pendingResetEmail == null) {
      throw const AuthFlowException('Start the password reset flow again.');
    }

    if (state.secondsUntilResend > 0) {
      throw AuthFlowException(
        'Resend available in ${state.secondsUntilResend}s.',
      );
    }

    await requestOtp(state.pendingResetEmail!);
  }

  Future<void> verifyOtp(String otp) async {
    if (state.pendingResetEmail == null) {
      throw const AuthFlowException('Start the password reset flow again.');
    }

    final result = await _apiClient.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {
        'email': state.pendingResetEmail,
        'otp': otp.trim(),
      },
      parser: (data) =>
          (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );

    switch (result) {
      case Success(:final data):
        final resetToken = data['resetToken'] as String;

        state = state.copyWith(otpVerified: true, resetToken: resetToken);
        await _storage.writeBool(_AuthStorageKeys.otpVerified, true);
        await _storage.writeString(_AuthStorageKeys.resetToken, resetToken);

      case ResultFailure(:final error):
        throw AuthFlowException(error.message);
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!state.otpVerified ||
        state.pendingResetEmail == null ||
        state.resetToken == null) {
      throw const AuthFlowException(
        'Verify the OTP before resetting password.',
      );
    }

    final result = await _apiClient.post<dynamic>(
      '/auth/reset-password',
      data: {
        'email': state.pendingResetEmail,
        'resetToken': state.resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          isAuthenticated: false,
          otpVerified: false,
          clearPendingResetEmail: true,
          clearOtpRequestedAt: true,
          clearResetToken: true,
        );

        await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
        await _storage.writeBool(_AuthStorageKeys.otpVerified, false);
        await _storage.remove(_AuthStorageKeys.pendingResetEmail);
        await _storage.remove(_AuthStorageKeys.otpRequestedAt);
        await _storage.remove(_AuthStorageKeys.resetToken);

      case ResultFailure(:final error):
        throw AuthFlowException(error.message);
    }
  }

  Future<void> logout() async {
    final token = state.accessToken;

    if (token != null) {
      await _apiClient.post<dynamic>(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    }

    state = state.copyWith(isAuthenticated: false, clearTokens: true);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
    await _storage.remove(_AuthStorageKeys.accessToken);
    await _storage.remove(_AuthStorageKeys.refreshToken);
  }

  Future<void> _persistSession({required bool rememberMe}) async {
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, true);
    await _storage.writeBool(_AuthStorageKeys.rememberMe, rememberMe);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
    await _storage.writeString(_AuthStorageKeys.fullName, state.fullName);
    await _storage.writeString(_AuthStorageKeys.email, state.email);
    await _storage.writeString(_AuthStorageKeys.phone, state.phone);
    if (state.userId != null) {
      await _storage.writeString(_AuthStorageKeys.userId, state.userId!);
    }
    if (state.role != null) {
      await _storage.writeString(_AuthStorageKeys.role, state.role!);
    }
    if (state.accessToken != null) {
      await _storage.writeString(
        _AuthStorageKeys.accessToken,
        state.accessToken!,
      );
    }
    if (state.refreshToken != null) {
      await _storage.writeString(
        _AuthStorageKeys.refreshToken,
        state.refreshToken!,
      );
    }
  }
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
  static const rememberMe = 'buyer_remember_me';
  static const accessToken = 'buyer_access_token';
  static const refreshToken = 'buyer_refresh_token';
  static const userId = 'buyer_user_id';
  static const role = 'buyer_role';
  static const pendingResetEmail = 'buyer_pending_reset_email';
  static const otpRequestedAt = 'buyer_otp_requested_at';
  static const otpVerified = 'buyer_otp_verified';
  static const resetToken = 'buyer_reset_token';
}
