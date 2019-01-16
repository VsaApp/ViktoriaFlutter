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
  String url = 'https://api.vsa.2bad2c0.de/unitplan/' +
      _grade +
      '.json?v=' +
      new Random().nextInt(99999999).toString();
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

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String grade = sharedPreferences.getString(Keys.grade);

  // Get all unitplan and exams tags...
  Map<String, dynamic> allTags = await OneSignal.shared.getTags();
  allTags.removeWhere(
      (key, value) => !key.startsWith('unitPlan') && !key.startsWith('exams'));

  // Get all selected subjects...
  List<String> subjects = [];
  getUnitPlan().forEach((day) {
    day.lessons.forEach((lesson) {
      int selected = sharedPreferences.getInt(Keys.unitPlan(grade,
          block: lesson.subjects[0].block,
          day: getUnitPlan().indexOf(day),
          unit: day.lessons.indexOf(lesson)));
      if (selected == null) {
        return;
      }
      subjects.add(lesson.subjects[selected].lesson);
    });
  });

  // Remove all lunch times...
  subjects = subjects.where((subject) {
    return subject.length < 3;
  }).toList();

  // Remove double subjects...
  subjects = subjects.toSet().toList();

  // Get all new exams tags...
  Map<String, dynamic> newTags = {};
  subjects.forEach((subject) => newTags[Keys.exams(grade, subject)] = sharedPreferences.getBool(Keys.exams(grade, subject)) ?? true);
  
  // Only set tags when the user activated notifications...
  if (sharedPreferences.getBool(Keys.getReplacementPlanNotifications) ??
      true) {

    // Set all new unitplan tags...
    getUnitPlan().forEach((day) {
      day.lessons.forEach((lesson) {
        newTags[Keys.unitPlan(grade,
                block: lesson.subjects[0].block,
                day: getUnitPlan().indexOf(day),
                unit: day.lessons.indexOf(lesson))] = sharedPreferences.getInt(Keys.unitPlan(grade,
                    block: lesson.subjects[0].block,
                    day: getUnitPlan().indexOf(day),
                    unit: day.lessons.indexOf(lesson)))
                .toString();
      });
    });
  }

  // Compare new and old tags...
  Map<String, dynamic> tagsToUpdate = {};
  List<String> tagsToRemove = [];
  // Get all removed and changed tags...
  allTags.forEach((key, value) {
    if (!newTags.containsKey(key)) tagsToRemove.add(value);
    else if (value != newTags[key]) tagsToUpdate[key] = newTags[key];
  });
  // Get all new tags...
  newTags.keys.where((key) => !allTags.containsKey(key)).forEach((key) => tagsToUpdate[key] = newTags[key]);

  OneSignal.shared.deleteTags(tagsToRemove);
  OneSignal.shared.sendTags(tagsToUpdate);
}
