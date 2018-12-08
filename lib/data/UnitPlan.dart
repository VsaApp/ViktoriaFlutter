import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/UnitPlan.dart';

Future download() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  try {
    String _url = 'https://api.vsa.2bad2c0.de/unitplan/' +
        _grade +
        '.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    sharedPreferences.setString(Keys.unitPlan + _grade, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.unitPlan + _grade) == null) {
      sharedPreferences.setString(Keys.unitPlan + _grade, '[]');
    }
  }

  UnitPlan.days = await fetchDays();
  UnitPlan.setAllSelections(sharedPreferences);
}

List<UnitPlanDay> getUnitPlan() {
  return UnitPlan.days;
}

Future<List<UnitPlanDay>> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  return parseDays(sharedPreferences.getString(Keys.unitPlan + _grade));
}

List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}
