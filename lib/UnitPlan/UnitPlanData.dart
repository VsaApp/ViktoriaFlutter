import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:onesignal/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import './UnitPlanModel.dart';

// Download the unit plan...
Future download() async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  String url = 'https://api.vsa.2bad2c0.de/unitplan/' + _grade + '.json?v=' + new Random().nextInt(99999999).toString(); 
  await fetchDataAndSave(url, Keys.unitPlan(_grade), '[]');

  // Parse data...
  UnitPlan.days = await fetchDays();

  // Set default selections...
  UnitPlan.setAllSelections(sharedPreferences);
}

// Returns the static unit plan...
List<UnitPlanDay> getUnitPlan() {
  return UnitPlan.days;
}

// Get unit plan from preferences...
Future<List<UnitPlanDay>> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  return parseDays(sharedPreferences.getString(Keys.unitPlan(_grade)));
}

// Returns parsed unit plan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}

// Sync the onesignal tags...
Future syncTags() async {
  if (!(await checkOnline)) return;

  // First delete all unitPLan tags...
  Map<String, dynamic> tagsToRemove = await OneSignal.shared.getTags();
  tagsToRemove.removeWhere((key, value) => !key.startsWith('unitPlan'));
  tagsToRemove.forEach((key, value) {
    OneSignal.shared.deleteTag(key);
  });

  // Only set tags when the user activated notifications...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (!(sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
      true)) {
    return;
  }

  // Set all tags...
  getUnitPlan().forEach((day) {
    day.lessons.forEach((lesson) {
      String grade = sharedPreferences.getString(Keys.grade);
      OneSignal.shared.sendTag(Keys.unitPlan(grade, block: lesson.subjects[0].block, day: getUnitPlan().indexOf(day), unit: day.lessons.indexOf(lesson)),
          sharedPreferences.getInt(Keys.unitPlan(grade, block: lesson.subjects[0].block, day: getUnitPlan().indexOf(day), unit: day.lessons.indexOf(lesson))).toString());
    });
  });
}
