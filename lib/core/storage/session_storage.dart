import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String _key = 'santri_session_json';

  Future<void> save(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
