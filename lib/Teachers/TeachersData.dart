import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Network.dart';

import 'TeachersModel.dart';

// Download the unit plan...
Future<Map<String, String>> download() async {
  // Get the selected grade...
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String url = 'https://api.vsa.2bad2c0.de/teachers/teachers.json';
  await fetchDataAndSave(url, Keys.teachers, '[]');

  // Parse data...
  Teachers.teachers = await fetchTeachers();
}

// Returns the static teachers...
List<Teacher> getTeachers() {
  return Teachers.teachers;
}

// Get teachers from preferences...
Future<List<Teacher>> fetchTeachers() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseTeachers(sharedPreferences.getString(Keys.teachers));
}

// Returns parsed teachers...
List<Teacher> parseTeachers(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Teacher>((json) => Teacher.fromJson(json)).toList();
}
