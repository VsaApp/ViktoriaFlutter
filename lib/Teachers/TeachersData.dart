import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

// Download the timetable...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    await fetchDataAndSave(Urls.teachers, Keys.teachers, '[]', onFinished: (int v) => successfully = v == 200);
  }

  // Parse data...
  Data.teachers = fetchTeachers();
  if (onFinished != null) onFinished(successfully);
}

/// Returns the static teachers...
List<Teacher> getTeachers() {
  return Data.teachers;
}

/// Get teachers from preferences...
List<Teacher> fetchTeachers() {
  return parseTeachers(Storage.getString(Keys.teachers));
}

/// Returns parsed teachers...
List<Teacher> parseTeachers(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Teacher>((json) => Teacher.fromJson(json)).toList();
}
