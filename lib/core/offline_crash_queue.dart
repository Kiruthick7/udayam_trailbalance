import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCrashQueue {
  static const _key = 'offline_crash_queue';

  static Future<void> addCrash(Map<String, dynamic> crash) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_key) ?? [];
    queue.add(jsonEncode(crash));
    await prefs.setStringList(_key, queue);
  }

  static Future<List<Map<String, dynamic>>> getCrashes() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_key) ?? [];
    return queue.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
