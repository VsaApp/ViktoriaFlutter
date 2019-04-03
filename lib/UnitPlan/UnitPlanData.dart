import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../Keys.dart';
import '../Network.dart';
import '../Selection.dart';
import '../Storage.dart';
import 'UnitPlanModel.dart';

/// Downloads the unit plan
/// 
/// Grade defines for which grade the unitplan should be download.
/// If temp is true, the downloaded unitplan will be returned and not set in the static class (Default temp is false).
/// If update is true, the untiplan will be downloaded from the server and if not it only would be loaded from the storage.
Future<List<UnitPlanDay>> download(String grade, bool temp,
    {bool update = true}) async {
  // Check if a date is selected...
  List<String> uVersion = Storage.getStringList(Keys.historyDate('unitplan'));
  List<String> rVersion =
  Storage.getStringList(Keys.historyDate('replacementplan'));

  String url;
  Map<String, dynamic> body;

  if (uVersion == null && rVersion == null ||
      !(Storage.getBool(Keys.dev) ?? false)) {
    url =
        '/unitplan/$grade.json?v=${Random().nextInt(99999999)}';
  } else {
    url = '/injectedunitplan/$grade';
    if (rVersion != null) {
      List<String> date =
      Storage.getStringList(Keys.historyDate('replacementplan'));
      body = {
        'replacementplanFile': '${date[0]}/${date[1]}/${date[2]}/${date[4]}'
      };
    }
  }
  if (update) {
    await fetchDataAndSave(url, Keys.unitPlan(grade),
        '{"participant": "5a", "date": "01.01.00", "data": []}',
        body: body);
  }

  // Parse data...
  if (!(temp ?? false)) {
    UnitPlan.days = await fetchDays(grade);

    // Set default selections...
    UnitPlan.setAllSelections();

    // Convert old selection format...
    convertFromOldVerion();

    return null;
  } else {
    return await fetchDays(grade);
  }
}

// Returns the static unit plan...
List<UnitPlanDay> getUnitPlan() {
  return UnitPlan.days;
}

// Get unit plan from preferences...
Future<List<UnitPlanDay>> fetchDays(String grade) async {
  return parseDays(Storage.getString(Keys.unitPlan(grade)));
}

Future<String> fetchDate(String grade) async {
  return parseDate(Storage.getString(Keys.unitPlan(grade)));
}

String parseDate(String responseBody) {
  final parsed = json.decode(responseBody)['date'] as String;
  return parsed;
}

// Returns parsed unit plan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}
