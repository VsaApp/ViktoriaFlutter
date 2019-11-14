import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

/// Downloads the timetable
///
/// If temp is true, the downloaded timetable will be returned and not set in the static class (Default temp is false).
///
/// If update is true, the timetable will be downloaded from the server and if not it only would be loaded from the storage.
Future<Timetable> download(bool temp,
    {bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  String grade = Storage.getString(Keys.grade);

  if (update) {
    // Default timetable (Only for download errors)
    String defaultTimetable = json.encode({
      'grade': grade,
      'date': DateTime.now().toIso8601String(),
      'data': {'grade': grade, 'days': []}
    });
    String oldTimetable = Storage.getString(Keys.timetable(grade));
    await fetchDataAndSave(
      Urls.timetable,
      Keys.timetable(grade),
      defaultTimetable,
      onFinished: (int v) => successfully = v == StatusCodes.success,
    );
    String newTimetable = Storage.getString(Keys.timetable(grade));
    if (oldTimetable != null) {
      await checkTimetableUpdated(oldTimetable, newTimetable);
    }
  }

  // Parse data...
  if (!(temp ?? false)) {
    Data.timetable = fetchTimetable(grade);

    // Set default selections...
    Data.timetable.setAllSelections();
  } else {
    if (onFinished != null) onFinished(successfully);
    return fetchTimetable(grade);
  }
  if (onFinished != null) onFinished(successfully);
  return null;
}

/// Returns the static timetable...
List<TimetableDay> getTimetable() {
  return Data.timetable.days;
}

/// Get timetable from preferences...
Timetable fetchTimetable(String grade) {
  return parseTimetable(Storage.getString(Keys.timetable(grade)));
}

/// Returns parsed timetable...
Timetable parseTimetable(String responseBody) {
  final parsed = json.decode(responseBody);
  return Timetable.fromJSON(parsed);
}

/// Resets the selected subjects when the timetable changed
Future checkTimetableUpdated(String version1, String version2) async {
  if (version1 != version2) {
    Storage.setBool(Keys.timetableIsNew, true);
    print('There is a new timetable, reset old data');
    List<String> keys = Storage.getKeys();
    List<String> keysToReset = keys
        .where((String key) => key.startsWith(Keys.selection('')) || key.startsWith(Keys.exams('')))
        .toList();
    keysToReset.forEach((String key) => Storage.remove(key));
    await deleteTags({
      'timestamp': Storage.getString(Keys.lastModified),
      'selected': keys.where((String key) => key.startsWith(Keys.selection(''))).toList(),
      'exams': keys.where((String key) => key.startsWith(Keys.exams(''))).toList()
    });
  }
}
