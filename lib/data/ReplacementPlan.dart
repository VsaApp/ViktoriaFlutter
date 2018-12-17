import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/ReplacementPlan.dart';

Future download(String _grade, {bool alreadyLoad}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await downloadDay(sharedPreferences, _grade, "today");
  await downloadDay(sharedPreferences, _grade, "tomorrow");

  if (alreadyLoad ?? true) load(_grade);
}

Future<List<ReplacementPlanDay>> load(String _grade, {bool temp, bool setOnlyColor, bool setFilter}) async {
  List<ReplacementPlanDay> days = await fetchDays(_grade);
  if (DateTime(
        (int.parse(days[0].date.split('.')[2]) < 2000) ? (int.parse(days[0].date.split('.')[2]) + 2000) : (int.parse(days[0].date.split('.')[2])),
        int.parse(days[0].date.split('.')[1]),
        int.parse(days[0].date.split('.')[0])
      ).isAfter(DateTime(
        (int.parse(days[1].date.split('.')[2]) < 2000) ? (int.parse(days[1].date.split('.')[2]) + 2000) : (int.parse(days[1].date.split('.')[2])),
        int.parse(days[1].date.split('.')[1]),
        int.parse(days[1].date.split('.')[0])
      ))
    ) {
    days = [days[1], days[0]];
  }
  else if (days[0].date == days[1].date){
    if (DateTime(
        (int.parse(days[0].update.split('.')[2]) < 2000) ? (int.parse(days[0].update.split('.')[2]) + 2000) : (int.parse(days[0].update.split('.')[2])),
        int.parse(days[0].update.split('.')[1]),
        int.parse(days[0].update.split('.')[0]),
        int.parse(days[0].time.split(':')[0]),
        int.parse(days[0].time.split(':')[1])
      ).isAfter(DateTime(
        (int.parse(days[1].date.split('.')[2]) < 2000) ? (int.parse(days[1].date.split('.')[2]) + 2000) : (int.parse(days[1].date.split('.')[2])),
        int.parse(days[1].date.split('.')[1]),
        int.parse(days[1].date.split('.')[0]),
        int.parse(days[1].time.split(':')[0]),
        int.parse(days[1].time.split(':')[1])
      ))
      ) {
      days = [days[1]];
    }
    else {
      days = [days[0]];
    }
  }

  if (setOnlyColor ?? false) setFilter = false;

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (setFilter ?? true) days.forEach((day) => day.insertInUnitPlan(sharedPreferences));
  else if (setOnlyColor ?? false) days.forEach((day) => day.setColors());
  if (!(temp ?? false)) ReplacementPlan.days = days;
  else return days;
  return null;
}

Future downloadDay(SharedPreferences sharedPreferences, String _grade,
    String _day) async {
  try {
    String _url = 'https://api.vsa.2bad2c0.de/replacementplan/' +
        _day +
        '/' +
        _grade +
        '.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    await sharedPreferences.setString(
        Keys.replacementPlan + _grade + _day, response.body);
    await sharedPreferences.commit();
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
