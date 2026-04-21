import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStorage {
  String? readString(String key);
  int? readInt(String key);
  bool? readBool(String key);
  double? readDouble(String key);
  List<String>? readStringList(String key);

  Future<void> writeString(String key, String value);
  Future<void> writeInt(String key, int value);
  Future<void> writeBool(String key, bool value);
  Future<void> writeDouble(String key, double value);
  Future<void> writeStringList(String key, List<String> value);
  Future<void> remove(String key);
  Future<void> clear();
}

final class SharedPreferencesStorage implements KeyValueStorage {
  const SharedPreferencesStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? readString(String key) => _preferences.getString(key);

  @override
  int? readInt(String key) => _preferences.getInt(key);

  @override
  bool? readBool(String key) => _preferences.getBool(key);

  @override
  double? readDouble(String key) => _preferences.getDouble(key);

  @override
  List<String>? readStringList(String key) => _preferences.getStringList(key);

  @override
  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  @override
  Future<void> writeDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await _preferences.clear();
  }
}
