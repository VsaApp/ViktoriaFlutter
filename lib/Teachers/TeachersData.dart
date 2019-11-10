import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models/TeachersModel.dart';

// Download the timetable...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = '/teachers/teachers.json';
    await fetchDataAndSave(url, Keys.teachers, '[]', onFinished: (bool v) => successfully = v);
  }

  // Parse data...
  Teachers.teachers = await fetchTeachers();
  if (onFinished != null) onFinished(successfully);
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
