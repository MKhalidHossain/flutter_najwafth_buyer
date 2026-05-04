import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required this.password,
    required this.rememberMe,
    required this.pendingResetEmail,
    required this.pendingOtp,
    required this.otpRequestedAt,
    required this.otpVerified,
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
      rememberMe: storage.readBool(_AuthStorageKeys.rememberMe) ?? false,
      pendingResetEmail: storage.readString(_AuthStorageKeys.pendingResetEmail),
      pendingOtp: storage.readString(_AuthStorageKeys.pendingOtp),
      otpRequestedAt: _parseDateTime(
        storage.readString(_AuthStorageKeys.otpRequestedAt),
      ),
      otpVerified: storage.readBool(_AuthStorageKeys.otpVerified) ?? false,
    );
  }

  final bool onboardingCompleted;
  final bool isAuthenticated;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool rememberMe;
  final String? pendingResetEmail;
  final String? pendingOtp;
  final DateTime? otpRequestedAt;
  final bool otpVerified;

  bool get hasPendingOtp =>
      pendingResetEmail != null && pendingOtp != null && otpRequestedAt != null;

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
    bool? rememberMe,
    String? pendingResetEmail,
    String? pendingOtp,
    DateTime? otpRequestedAt,
    bool? otpVerified,
    bool clearPendingResetEmail = false,
    bool clearPendingOtp = false,
    bool clearOtpRequestedAt = false,
  }) {
    return AuthState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      pendingResetEmail: clearPendingResetEmail
          ? null
          : pendingResetEmail ?? this.pendingResetEmail,
      pendingOtp: clearPendingOtp ? null : pendingOtp ?? this.pendingOtp,
      otpRequestedAt: clearOtpRequestedAt
          ? null
          : otpRequestedAt ?? this.otpRequestedAt,
      otpVerified: otpVerified ?? this.otpVerified,
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
  final Random _random = Random();

  @override
  AuthState build() {
    _storage = ref.watch(keyValueStorageProvider);
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
    final normalizedEmail = email.trim().toLowerCase();
    // Allow any non-empty email and password to sign in for testing
    // if (normalizedEmail != state.email.trim().toLowerCase() ||
    //     password != state.password) {
    //   throw const AuthFlowException('Invalid email or password.');
    // }

    state = state.copyWith(
      isAuthenticated: true,
      rememberMe: rememberMe,
      onboardingCompleted: true,
    );

    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, true);
    await _storage.writeBool(_AuthStorageKeys.rememberMe, rememberMe);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      password: password,
      rememberMe: true,
      isAuthenticated: true,
      onboardingCompleted: true,
    );

    await _storage.writeString(_AuthStorageKeys.fullName, state.fullName);
    await _storage.writeString(_AuthStorageKeys.email, state.email);
    await _storage.writeString(_AuthStorageKeys.phone, state.phone);
    await _storage.writeString(_AuthStorageKeys.password, state.password);
    await _storage.writeBool(_AuthStorageKeys.rememberMe, true);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, true);
    await _storage.writeBool(_AuthStorageKeys.onboarding, true);
  }

  Future<String> requestOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != state.email.trim().toLowerCase()) {
      throw const AuthFlowException('No account found for this email.');
    }

    final otp = _generateOtp();
    final now = DateTime.now();

    state = state.copyWith(
      pendingResetEmail: normalizedEmail,
      pendingOtp: otp,
      otpRequestedAt: now,
      otpVerified: false,
    );

    await _storage.writeString(
      _AuthStorageKeys.pendingResetEmail,
      normalizedEmail,
    );
    await _storage.writeString(_AuthStorageKeys.pendingOtp, otp);
    await _storage.writeString(
      _AuthStorageKeys.otpRequestedAt,
      now.toIso8601String(),
    );
    await _storage.writeBool(_AuthStorageKeys.otpVerified, false);

    return otp;
  }

  Future<String> resendOtp() async {
    if (state.pendingResetEmail == null) {
      throw const AuthFlowException('Start the password reset flow again.');
    }

    if (state.secondsUntilResend > 0) {
      throw AuthFlowException(
        'Resend available in ${state.secondsUntilResend}s.',
      );
    }

    return requestOtp(state.pendingResetEmail!);
  }

  Future<void> verifyOtp(String otp) async {
    if (!state.hasPendingOtp) {
      throw const AuthFlowException('Start the password reset flow again.');
    }

    if (otp.trim() != state.pendingOtp) {
      throw const AuthFlowException('The OTP code is incorrect.');
    }

    state = state.copyWith(otpVerified: true);
    await _storage.writeBool(_AuthStorageKeys.otpVerified, true);
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!state.otpVerified || state.pendingResetEmail == null) {
      throw const AuthFlowException(
        'Verify the OTP before resetting password.',
      );
    }

    if (newPassword != confirmPassword) {
      throw const AuthFlowException('Passwords do not match.');
    }

    state = state.copyWith(
      password: newPassword,
      isAuthenticated: false,
      otpVerified: false,
      clearPendingOtp: true,
      clearPendingResetEmail: true,
      clearOtpRequestedAt: true,
    );

    await _storage.writeString(_AuthStorageKeys.password, newPassword);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
    await _storage.writeBool(_AuthStorageKeys.otpVerified, false);
    await _storage.remove(_AuthStorageKeys.pendingResetEmail);
    await _storage.remove(_AuthStorageKeys.pendingOtp);
    await _storage.remove(_AuthStorageKeys.otpRequestedAt);
  }

  Future<void> logout() async {
    state = state.copyWith(isAuthenticated: false);
    await _storage.writeBool(_AuthStorageKeys.isAuthenticated, false);
  }

  String _generateOtp() {
    final value = 100000 + _random.nextInt(900000);
    return value.toString();
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
  static const password = 'buyer_password';
  static const rememberMe = 'buyer_remember_me';
  static const pendingResetEmail = 'buyer_pending_reset_email';
  static const pendingOtp = 'buyer_pending_otp';
  static const otpRequestedAt = 'buyer_otp_requested_at';
  static const otpVerified = 'buyer_otp_verified';
}
