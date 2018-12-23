import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/WorkGroups.dart';

// Download work groups data...
Future download() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    // Get url...
    String _url = 'https://api.vsa.2bad2c0.de/workgroups/workgroups.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    // Save loaded data...
    sharedPreferences.setString(Keys.workGroups, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.workGroups) == null) {
      // Set default data...
      sharedPreferences.setString(Keys.workGroups, '[]');
    }
  }

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
