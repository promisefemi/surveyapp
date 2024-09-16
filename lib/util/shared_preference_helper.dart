import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static late SharedPreferencesHelper _instance;
  static late SharedPreferences _preferences;

  static Future<SharedPreferencesHelper> getInstance() async {
    _instance = SharedPreferencesHelper();
    _preferences = await SharedPreferences.getInstance();
    return _instance;
  }

  Future<bool> remove(
    String key,
  ) async {
    return await _preferences.remove(key);
  }

  Future<bool> setMap(String key, Map<String, dynamic> value) async {
    return await _preferences.setString(key, json.encode(value));
  }

  Map<String, dynamic>? getMap(String key) {
    String? value = _preferences.getString(key);
    if (value != null) {
      return json.decode(value);
    }
    return null;
  }

  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }
}
