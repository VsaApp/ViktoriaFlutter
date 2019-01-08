import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../Keys.dart';
import '../Network.dart';
import 'WorkGroupsModel.dart';

// Download work groups data...
Future download() async {
  String url = 'https://api.vsa.2bad2c0.de/workgroups/workgroups.json?v=' + new Random().nextInt(99999999).toString();
  await fetchDataAndSave(url, Keys.workGroups, '[]');

  // Parse loaded data...
  WorkGroups.days = await fetchGroups();
}

// Returns the static work groups data...
List<WorkGroupsDay> getWorkGroups() {
  return WorkGroups.days;
}

// Load work groups from preferences...
Future<List<WorkGroupsDay>> fetchGroups() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseGroups(sharedPreferences.getString(Keys.workGroups));
}

// Returns parse work groups days...
List<WorkGroupsDay> parseGroups(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed
      .map<WorkGroupsDay>((json) => WorkGroupsDay.fromJson(json))
      .toList();
}
