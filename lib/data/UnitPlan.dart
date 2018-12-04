import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UnitPlan.dart';
import '../Keys.dart';

Future download() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  try {
    String _url = 'https://api.vsa.lohl1kohl.de/sp/' +
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
}

List<UnitPlanDay> getUnitPlan(){
  return UnitPlan.days;
}

Future<List<UnitPlanDay>> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String _grade = sharedPreferences.getString(Keys.grade);
  return parseDays(sharedPreferences.getString(Keys.unitPlan + _grade));
}

List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}
