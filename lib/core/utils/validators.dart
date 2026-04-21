final class Validators {
  const Validators._();

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = required(value, label: 'Email');
    if (requiredMessage != null) {
      return requiredMessage;
    }

    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? minLength(
    String? value,
    int length, {
    String label = 'Value',
  }) {
    final requiredMessage = required(value, label: label);
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (value!.trim().length < length) {
      return '$label must be at least $length characters.';
    }

    return null;
  }
}
