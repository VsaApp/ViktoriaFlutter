import 'package:shared_preferences/shared_preferences.dart';

import './HistoryDialogModel.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../../Keys.dart';
import '../../Network.dart';

// Download the unit plan...
Future<List<Year>> download(String type) async {
  String url = 'https://history.api.vsa.2bad2c0.de/$type?v=${Random().nextInt(99999999)}';
  await fetchDataAndSave(url, Keys.history(type), '[]');

  return await fetchDays(type);
}

// Get unit plan from preferences...
Future<List<Year>> fetchDays(String type) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseDays(sharedPreferences.getString(Keys.history(type)));
}

// Returns parsed unit plan...
List<Year> parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Year>((json) => Year.fromJson(json)).toList();
}
