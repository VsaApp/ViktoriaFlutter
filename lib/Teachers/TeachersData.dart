import 'dart:async';
import 'dart:convert';

import '../Keys.dart';
import '../Network.dart';
import '../Storage.dart';
import 'TeachersModel.dart';

// Download the unit plan...
Future<Map<String, String>> download({bool update = true}) async {
  if (update) {
    String url = '/teachers/teachers.json';
    await fetchDataAndSave(url, Keys.teachers, '[]');
  }

  // Parse data...
  Teachers.teachers = await fetchTeachers();
}

// Returns the static teachers...
List<Teacher> getTeachers() {
  return Teachers.teachers;
}

// Get teachers from preferences...
Future<List<Teacher>> fetchTeachers() async {
  return parseTeachers(Storage.getString(Keys.teachers));
}

// Returns parsed teachers...
List<Teacher> parseTeachers(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Teacher>((json) => Teacher.fromJson(json)).toList();
}
