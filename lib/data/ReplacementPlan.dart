import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/ReplacementPlan.dart';

Future download(String _grade, bool _save) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //String _grade = sharedPreferences.getString(Keys.grade);
  await downloadDay(sharedPreferences, _grade, "today", _save);
  await downloadDay(sharedPreferences, _grade, "tomorrow", _save);

  ReplacementPlan.days = await fetchDays(_grade);
  for (int i = 0; i < 2; i++)
    ReplacementPlan.days[i]
        .insertInUnitPlan(await SharedPreferences.getInstance());
}

Future downloadDay(SharedPreferences sharedPreferences, String _grade,
    String _day, bool _save) async {
  try {
    String _url = 'https://api.vsa.2bad2c0.de/replacementplan/' +
        _day +
        '/' +
        _grade +
        '.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    if (_save) {
      await sharedPreferences.setString(
          Keys.replacementPlan + _grade + _day, response.body);
      await sharedPreferences.commit();
    }
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.replacementPlan + _grade + _day) ==
        null) {
      await sharedPreferences.setString(
          Keys.replacementPlan + _grade + _day, '[]');
      await sharedPreferences.commit();
    }
  }
}

List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}

Future<List<ReplacementPlanDay>> fetchDays(String _grade) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(
      sharedPreferences.getString(Keys.replacementPlan + _grade + "today"),
      sharedPreferences.getString(Keys.replacementPlan + _grade + "tomorrow"));
}

List<ReplacementPlanDay> parseDays(String _today, String _tomorrow) {
  final today = json.decode(_today);
  final tomorrow = json.decode(_tomorrow);

  return [
    ReplacementPlanDay.fromJson(today),
    ReplacementPlanDay.fromJson(tomorrow)
  ];
}
