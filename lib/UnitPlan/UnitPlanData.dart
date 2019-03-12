import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import './UnitPlanModel.dart';
import '../Keys.dart';
import '../Selection.dart';
import '../Network.dart';

// Download the unit plan...
Future<List<UnitPlanDay>> download(String grade, bool temp) async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Check if a date is selected...
  List<String> uVersion =
      sharedPreferences.getStringList(Keys.historyDate('unitplan'));
  List<String> rVersion =
      sharedPreferences.getStringList(Keys.historyDate('replacementplan'));

  String url;
  Map<String, dynamic> body;

  if (uVersion == null && rVersion == null ||
      !(sharedPreferences.getBool(Keys.dev) ?? false)) {
    url =
        'https://api.vsa.2bad2c0.de/unitplan/$grade.json?v=${Random().nextInt(99999999)}';
  } else {
    url = 'https://history.api.vsa.2bad2c0.de/injectedunitplan/$grade';
    if (rVersion != null) {
      List<String> date =
          sharedPreferences.getStringList(Keys.historyDate('replacementplan'));
      body = {
        'replacementplanFile': '${date[0]}/${date[1]}/${date[2]}/${date[4]}'
      };
    }
  }

  await fetchDataAndSave(url, Keys.unitPlan(grade), '[]', body: body);

  // Parse data...
  if (!(temp ?? false)) {
    UnitPlan.days = await fetchDays(grade);

    // Set default selections...
    await UnitPlan.setAllSelections(sharedPreferences);

    // Convert old selection format...
    await convertFromOldVerion(sharedPreferences);
    logValues(sharedPreferences);

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

Future<String> fetchDate(String grade) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDate(sharedPreferences.getString(Keys.unitPlan(grade)));
}

String parseDate(String responseBody) {
  final parsed = json.decode(responseBody)['date'] as String;
  return parsed;
}

// Returns parsed unit plan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}
