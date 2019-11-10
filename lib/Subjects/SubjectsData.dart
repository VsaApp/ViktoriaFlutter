import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models/SubjectsModel.dart';

// Download the timetable...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = '/subjects';
    await fetchDataAndSave(url, Keys.subjects, '{}', onFinished: (bool v) => successfully = v);
  }

  // Parse data...
  Subjects.subjects = await fetchSubjects();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static subjects...
Map<String, String> getSubjects() {
  return Subjects.subjects;
}

// Get subjects from preferences...
Future<Map<String, String>> fetchSubjects() async {
  return parseSubjects(Storage.getString(Keys.subjects));
}

// Returns parsed subjects...
Map<String, String> parseSubjects(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, String>();
  return parsed;
}
