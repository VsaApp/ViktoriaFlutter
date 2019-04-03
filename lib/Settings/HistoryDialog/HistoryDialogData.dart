import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../../Keys.dart';
import '../../Network.dart';
import '../../Storage.dart';
import 'HistoryDialogModel.dart';

// Download the unit plan...
Future<List<Year>> download(String type) async {
  String url = '$historyUrl/$type?v=${Random().nextInt(99999999)}';
  await fetchDataAndSave(url, Keys.history(type), '[]',
      timeout: Duration(minutes: 1));

  return await fetchDays(type);
}

// Get unit plan from preferences...
Future<List<Year>> fetchDays(String type) async {
  return parseDays(Storage.getString(Keys.history(type)));
}

// Returns parsed unit plan...
List<Year> parseDays(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Year>((json) => Year.fromJson(json)).toList();
}
