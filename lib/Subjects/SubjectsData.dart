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
    await fetchDataAndSave(Urls.subjects, Keys.subjects, '{}', onFinished: (int v) => successfully = v == 200);
  }

  // Parse data...
  Data.subjects = fetchSubjects();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static subjects...
Map<String, String> getSubjects() {
  return Data.subjects;
}

// Get subjects from preferences...
Map<String, String> fetchSubjects() {
  return parseSubjects(Storage.getString(Keys.subjects));
}

// Returns parsed subjects...
Map<String, String> parseSubjects(String responseBody) {
  final parsed = json.decode(responseBody).map<String, String>((key, value) => MapEntry<String, String>(key, value as String));
  return parsed;
}