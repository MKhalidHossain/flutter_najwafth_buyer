import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be provided by AppBootstrap.');
});

final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  return SharedPreferencesStorage(ref.watch(sharedPreferencesProvider));
});
