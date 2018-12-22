import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/UnitPlan.dart';

// Download the unitplan...
Future download() async {

  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  try {
    // Get the url...
    String _url = 'https://api.vsa.2bad2c0.de/unitplan/' +
        _grade +
        '.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);

    // Save loaded data...
    sharedPreferences.setString(Keys.unitPlan + _grade, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    // Set to default data...
    if (sharedPreferences.getString(Keys.unitPlan + _grade) == null) {
      sharedPreferences.setString(Keys.unitPlan + _grade, '[]');
    }
  }

  // Parse data...
  UnitPlan.days = await fetchDays();

  // Set default selections... 
  UnitPlan.setAllSelections(sharedPreferences);
}

// Returns the static unitplan...
List<UnitPlanDay> getUnitPlan() {
  return UnitPlan.days;
}

// Get unitplan from preferences...
Future<List<UnitPlanDay>> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  return parseDays(sharedPreferences.getString(Keys.unitPlan + _grade));
}

// Returns parsed unitplan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}

// Sync the onesignal tags...
Future syncTags() async {
  Map<String, dynamic> tags = await OneSignal.shared.getTags();

  // First delete all tags...
  tags.forEach((key, value) {
    OneSignal.shared.deleteTag(key);
  });
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Only set tags when the user activated notifications...
  if (!(sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
      true)) {
    return;
  }

  // Set all tags...
  getUnitPlan().forEach((day) {
    day.lessons.forEach((lesson) {
      String prefKey = sharedPreferences.getString(Keys.grade) +
          '-' +
          (lesson.subjects[0].block == ''
              ? getUnitPlan().indexOf(day).toString() +
              '-' +
              day.lessons.indexOf(lesson).toString()
              : lesson.subjects[0].block);
      OneSignal.shared.sendTag(prefKey,
          sharedPreferences.getInt(Keys.unitPlan + prefKey).toString());
    });
  });
}
