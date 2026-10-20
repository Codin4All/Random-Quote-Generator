import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fitness_activity.dart';

class FitnessStorage {
  static const String _key = 'fitness_activities';

  static Future<List<FitnessActivity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_key);

    if (savedData == null) return [];

    final List<dynamic> decoded = jsonDecode(savedData);

    return decoded
        .map(
          (item) => FitnessActivity.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<void> saveActivities(List<FitnessActivity> activities) async {
    final prefs = await SharedPreferences.getInstance();

    final data = activities.map((activity) => activity.toJson()).toList();

    await prefs.setString(_key, jsonEncode(data));
  }
}
