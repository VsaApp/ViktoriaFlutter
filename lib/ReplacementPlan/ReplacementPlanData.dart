import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import 'ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanModel.dart';

// Download all days of the replacement plan...
Future download(String _grade, {bool alreadyLoad = true}) async {
  await downloadDay(_grade, 'today');
  await downloadDay(_grade, 'tomorrow');

  if (alreadyLoad) load(_grade);
}

/* Load the replacement plan in the structure...
    - temp: return data or set static
    - setOnlyColor: set colors of changes and do not filter (Needs when the unitplan is not load for the correct grade)
*/
Future<List<ReplacementPlanDay>> load(String _grade,
    {bool temp, bool setOnlyColor, bool setFilter, List<UnitPlanDay> forDays}) async {
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
      days = [days[0]];
    } else {
      days = [days[1]];
    }
  }

  // When only set colors, do not filter the changes...
  if (setOnlyColor ?? false) setFilter = false;

  // Set the filter and insert the replacement plan in the unitplan or only set the colors...
  if (setFilter ?? true) {
    days.forEach((day) => day.insertInUnitPlan(sharedPreferences, forDays ?? UnitPlan.days));
  }
  else if (setOnlyColor ?? false) days.forEach((day) => day.setColors());

  // Return or set the data in a static object...
  if (!(temp ?? false))
    ReplacementPlan.days = days;
  else
    return days;
  return null;
}

// Download one day...
Future downloadDay(String _grade, String _day) async {
  String url = 'https://api.vsa.2bad2c0.de/replacementplan/' + _day + '/' + _grade + '.json?v=' + Random().nextInt(99999999).toString(); 
  await fetchDataAndSave(url, Keys.replacementPlan(_grade, _day), '[]');
}

// Returns the static replacement plan...
List<ReplacementPlanDay> getReplacementPlan() {
  return ReplacementPlan.days;
}

// Get data from preferences...
Future<List<ReplacementPlanDay>> fetchDays(String _grade) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(
      sharedPreferences.getString(Keys.replacementPlan(_grade, 'today')),
      sharedPreferences.getString(Keys.replacementPlan(_grade, 'tomorrow'))
  );
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
