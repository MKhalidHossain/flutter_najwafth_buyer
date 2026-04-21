import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

final class ThemeModeController extends Notifier<ThemeMode> {
  static const _storageKey = 'core.theme_mode';

  @override
  ThemeMode build() {
    final storage = ref.watch(keyValueStorageProvider);
    final savedValue = storage.readString(_storageKey);

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedValue,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(keyValueStorageProvider).writeString(_storageKey, mode.name);
  }

  Future<void> toggleLightDark() {
    return setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
