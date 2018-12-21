import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/WorkGroups.dart';

Future download() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    String _url = 'https://api.vsa.2bad2c0.de/workgroups/workgroups.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    sharedPreferences.setString(Keys.workGroups, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.workGroups) == null) {
      sharedPreferences.setString(Keys.workGroups, '[]');
    }
  }

  WorkGroups.days = await fetchDays();
}

List<WorkGroupsDay> getWorkGroups() {
  return WorkGroups.days;
}

Future<List<WorkGroupsDay>> fetchDays() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(sharedPreferences.getString(Keys.workGroups));
}

List<WorkGroupsDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed
      .map<WorkGroupsDay>((json) => WorkGroupsDay.fromJson(json))
      .toList();
}
