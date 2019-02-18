import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Network.dart';

import 'SubjectsModel.dart';

// Download the unit plan...
Future<Map<String, String>> download() async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String url = 'https://api.vsa.2bad2c0.de/subjects';
  await fetchDataAndSave(url, Keys.subjects, '{}');

  // Parse data...
  Subjects.subjects = await fetchSubjects();
}

// Returns the static subjects...
Map<String, String> getSubjects() {
  return Subjects.subjects;
}

// Get subjects from preferences...
Future<Map<String, String>> fetchSubjects() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseSubjects(sharedPreferences.getString(Keys.subjects));
}

// Returns parsed subjects...
Map<String, String> parseSubjects(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, String>();
  return parsed;
}
