import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'HistoryDialogModel.dart';

// Download the timetable...
Future<List<Year>> download(String type) async {
  String url = '$historyUrl/$type?v=${Random().nextInt(99999999)}';
  await fetchDataAndSave(url, Keys.history(type), '[]',
      timeout: Duration(minutes: 1));

  return await fetchDays(type);
}

// Get timetable from preferences...
Future<List<Year>> fetchDays(String type) async {
  return parseDays(Storage.getString(Keys.history(type)));
}

// Returns parsed timetable...
List<Year> parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Year>((json) => Year.fromJson(json)).toList();
}
