import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import './UnitPlanModel.dart';

// Download the unit plan...
Future<List<UnitPlanDay>> download(String grade, bool temp) async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String url =
      'https://api.vsa.2bad2c0.de/unitplan/$grade.json?v=${Random().nextInt(99999999)}';
  await fetchDataAndSave(url, Keys.unitPlan(grade), '[]');

  // Parse data...
  if (!(temp ?? false)) {
    UnitPlan.days = await fetchDays(grade);

    // Set default selections...
    UnitPlan.setAllSelections(sharedPreferences);
    return null;
  } else {
    return await fetchDays(grade);
  }
}

// Returns the static unit plan...
List<UnitPlanDay> getUnitPlan() {
  return UnitPlan.days;
}

// Get unit plan from preferences...
Future<List<UnitPlanDay>> fetchDays(String grade) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(sharedPreferences.getString(Keys.unitPlan(grade)));
}

// Returns parsed unit plan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}
