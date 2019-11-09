import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'TimetableModel.dart';

/// Downloads the timetable
///
/// Grade defines for which grade the timetable should be download.
/// If temp is true, the downloaded timetable will be returned and not set in the static class (Default temp is false).
/// If update is true, the untiplan will be downloaded from the server and if not it only would be loaded from the storage.
Future<List<TimetableDay>> download(String grade, bool temp,
    {bool update = true, Function(bool successfully) onFinished}) async {
  // Check if a date is selected...
  List<String> uVersion = Storage.getStringList(Keys.historyDate('timetable'));
  List<String> rVersion =
  Storage.getStringList(Keys.historyDate('substitutionPlan'));

  String url;
  Map<String, dynamic> body;
  bool successfully;

  if (uVersion == null && rVersion == null ||
      !(Storage.getBool(Keys.dev) ?? false)) {
    url = '/timetable/$grade.json?v=${Random().nextInt(99999999)}';
  } else {
    url = '$historyUrl/injectedtimetable/$grade';
    if (rVersion != null) {
      List<String> date =
      Storage.getStringList(Keys.historyDate('substitutionPlan'));
      body = {
        'substitutionPlanFile': '${date[0]}/${date[1]}/${date[2]}/${date[4]}'
      };
    }
  }
  if (update) {
    String defaultTimetable =
        '{"participant": "5a", "date": "01.01.00", "data": []}';
    String oldTimetable = Storage.getString(Keys.timetable(grade));
    await fetchDataAndSave(url, Keys.timetable(grade), defaultTimetable,
        body: body, onFinished: (bool v) => successfully = v);
    String newTimetable = Storage.getString(Keys.timetable(grade));
    if (oldTimetable != null) await checkTimetableUpdated(oldTimetable, newTimetable);
  }

  // Parse data...
  if (!(temp ?? false)) {
    Timetable.days = await fetchDays(grade);

    // Set default selections...
    Timetable.setAllSelections();

  } else {
    if (onFinished != null) onFinished(successfully);
    return await fetchDays(grade);
  }
  if (onFinished != null) onFinished(successfully);
  return null;
}

// Returns the static timetable...
List<TimetableDay> getTimetable() {
  return Timetable.days;
}

// Get timetable from preferences...
Future<List<TimetableDay>> fetchDays(String grade) async {
  return parseDays(Storage.getString(Keys.timetable(grade)));
}

Future<String> fetchDate(String grade) async {
  return parseDate(Storage.getString(Keys.timetable(grade)));
}

String parseDate(String responseBody) {
  final parsed = json.decode(responseBody)['date'] as String;
  return parsed;
}

/// Returns parsed timetable...
List<TimetableDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<TimetableDay>((json) => TimetableDay.fromJson(json)).toList();
}

/// Returns the timetable without any substitution plan data
String getFilteredString(String timetable) {
  final parsed = json.decode(timetable).cast<String, dynamic>()['data'];
  parsed.forEach((day) {
    day['substitutionPlan'] = null;
    day['lessons'].keys.toList().forEach((lesson) {
      day['lessons'][lesson].forEach((subject) {
        subject['course'] = null;
        subject['changes'] = null;
      });
    });
  });
  return json.encode(parsed);
}

/// Resets the selected subjects when the timetable changed
Future checkTimetableUpdated(String version1, String version2) async {
  try {
    if (getFilteredString(version1) != getFilteredString(version2)) {
      Storage.setBool(Keys.timetableIsNew, true);
      print('There is a new timetable, reset old data');
      List<String> keys = Storage.getKeys().toList();
      List<String> keysToReset = keys
          .where((String key) =>
      ((key.startsWith('room-') ||
          key.startsWith('exams') ||
          (key.startsWith('timetable') && key
              .split('-')
              .length > 2))))
          .toList();
      keysToReset.forEach((String key) => Storage.remove(key));
      await deleteTags(keysToReset);
    }
  } catch (_) {
    print('Failed to compare untiplan versions');
  }
}
