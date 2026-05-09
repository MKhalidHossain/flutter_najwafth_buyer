import '../localization/app_localizations.dart';

final class Validators {
  const Validators._();

  static String? required(
    String? value, {
    String? label,
    AppLocalizations? l10n,
  }) {
    final resolvedLabel = label ?? l10n?.requiredField ?? 'This field';
    if (value == null || value.trim().isEmpty) {
      return l10n?.requiredMessage(resolvedLabel) ?? '$resolvedLabel is required.';
    }
    return null;
  }

  static String? email(String? value, {AppLocalizations? l10n}) {
    final requiredMessage = required(
      value,
      label: l10n?.emailLabel ?? 'Email',
      l10n: l10n,
    );
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return l10n?.enterValidEmail ?? 'Enter a valid email address.';
    }

    return null;
  }

  static String? minLength(
    String? value,
    int length, {
    String? label,
    AppLocalizations? l10n,
  }) {
    final resolvedLabel = label ?? l10n?.valueLabel ?? 'Value';
    final requiredMessage = required(value, label: resolvedLabel, l10n: l10n);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (value!.trim().length < length) {
      return l10n?.minLengthMessage(resolvedLabel, length) ??
          '$resolvedLabel must be at least $length characters.';
    }

    return null;
  }
}
