import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/ReplacementPlan.dart';

// Download all days of the replacement plan...
Future download(String _grade, {bool alreadyLoad}) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await downloadDay(sharedPreferences, _grade, "today");
  await downloadDay(sharedPreferences, _grade, "tomorrow");

  if (alreadyLoad ?? true) load(_grade);
}

/* Load the replacement plan in the structure...
    - temp: return data or set static
    - setOnlyColor: set colors of changes and do not filter (Needs when the unitplan is not load for the correct grade)
*/
Future<List<ReplacementPlanDay>> load(String _grade,
    {bool temp, bool setOnlyColor, bool setFilter}) async {
  // Get data from preferences...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<ReplacementPlanDay> days = await fetchDays(_grade);

  // Sort days by date and time...
  // If the second day is older than the first, switch order of days...
  if (DateTime(
          (int.parse(days[0].date.split('.')[2]) < 2000)
              ? (int.parse(days[0].date.split('.')[2]) + 2000)
              : (int.parse(days[0].date.split('.')[2])),
          int.parse(days[0].date.split('.')[1]),
          int.parse(days[0].date.split('.')[0]))
      .isAfter(DateTime(
          (int.parse(days[1].date.split('.')[2]) < 2000)
              ? (int.parse(days[1].date.split('.')[2]) + 2000)
              : (int.parse(days[1].date.split('.')[2])),
          int.parse(days[1].date.split('.')[1]),
          int.parse(days[1].date.split('.')[0])))) {
    days = [days[1], days[0]];
  }
  // If the days are the same, compare the update time...
  else if (days[0].date == days[1].date) {
    if (DateTime(
            (int.parse(days[0].update.split('.')[2]) < 2000)
                ? (int.parse(days[0].update.split('.')[2]) + 2000)
                : (int.parse(days[0].update.split('.')[2])),
            int.parse(days[0].update.split('.')[1]),
            int.parse(days[0].update.split('.')[0]),
            int.parse(days[0].time.split(':')[0]),
            int.parse(days[0].time.split(':')[1]))
        .isAfter(DateTime(
            (int.parse(days[1].date.split('.')[2]) < 2000)
                ? (int.parse(days[1].date.split('.')[2]) + 2000)
                : (int.parse(days[1].date.split('.')[2])),
            int.parse(days[1].date.split('.')[1]),
            int.parse(days[1].date.split('.')[0]),
            int.parse(days[1].time.split(':')[0]),
            int.parse(days[1].time.split(':')[1])))) {
      days = [days[1]];
    } else {
      days = [days[0]];
    }
  }

  // When only set colors, do not filter the changes...
  if (setOnlyColor ?? false) setFilter = false;

  // Set the filter and insert the replacement plan in the unitplan or only set the colors...
  if (setFilter ?? true)
    days.forEach((day) => day.insertInUnitPlan(sharedPreferences));
  else if (setOnlyColor ?? false) days.forEach((day) => day.setColors());

  // Return or set the data in a static object...
  if (!(temp ?? false))
    ReplacementPlan.days = days;
  else
    return days;
  return null;
}

// Download one day...
Future downloadDay(
    SharedPreferences sharedPreferences, String _grade, String _day) async {
  try {
    // Get url...
    String _url = 'https://api.vsa.2bad2c0.de/replacementplan/' +
        _day +
        '/' +
        _grade +
        '.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);

    // Save the loaded data..
    await sharedPreferences.setString(
        Keys.replacementPlan + _grade + _day, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.replacementPlan + _grade + _day) ==
        null) {
      // Set to default data...
      await sharedPreferences.setString(
          Keys.replacementPlan + _grade + _day, '[]');
      await sharedPreferences.commit();
    }
  }
}

// Returns the static replacement plan...
List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}

// Get data from preferences...
Future<List<ReplacementPlanDay>> fetchDays(String _grade) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(
      sharedPreferences.getString(Keys.replacementPlan + _grade + "today"),
      sharedPreferences.getString(Keys.replacementPlan + _grade + "tomorrow"));
}

// Returns parsed data in the replacement plan structure...
List<ReplacementPlanDay> parseDays(String _today, String _tomorrow) {
  final today = json.decode(_today);
  final tomorrow = json.decode(_tomorrow);

  return [
    ReplacementPlanDay.fromJson(today),
    ReplacementPlanDay.fromJson(tomorrow)
  ];
}
