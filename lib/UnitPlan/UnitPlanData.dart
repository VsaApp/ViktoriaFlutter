import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import './UnitPlanModel.dart';

// Download the unit plan...
Future<List<UnitPlanDay>> download({String grade, bool setStatic = true}) async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = grade ?? sharedPreferences.getString(Keys.grade);
  String url = 'https://api.vsa.2bad2c0.de/unitplan/$_grade.json?v=${Random().nextInt(99999999)}';
  await fetchDataAndSave(url, Keys.unitPlan(_grade), '[]');

  // Parse data...
  if (setStatic) {
    UnitPlan.days = await fetchDays();

    // Set default selections...
    UnitPlan.setAllSelections(sharedPreferences);
    return null;
  }
  else return await fetchDays();
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

