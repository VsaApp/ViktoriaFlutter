import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'UnitPlanModel.dart';

/// Downloads the unit plan
///
/// Grade defines for which grade the unitplan should be download.
/// If temp is true, the downloaded unitplan will be returned and not set in the static class (Default temp is false).
/// If update is true, the untiplan will be downloaded from the server and if not it only would be loaded from the storage.
Future<List<UnitPlanDay>> download(String grade, bool temp,
    {bool update = true, Function(bool successfully) onFinished}) async {
  // Check if a date is selected...
  List<String> uVersion = Storage.getStringList(Keys.historyDate('unitplan'));
  List<String> rVersion =
  Storage.getStringList(Keys.historyDate('replacementplan'));

  String url;
  Map<String, dynamic> body;
  bool successfully;

  if (uVersion == null && rVersion == null ||
      !(Storage.getBool(Keys.dev) ?? false)) {
    url = '/unitplan/$grade.json?v=${Random().nextInt(99999999)}';
  } else {
    url = '$historyUrl/injectedunitplan/$grade';
    if (rVersion != null) {
      List<String> date =
      Storage.getStringList(Keys.historyDate('replacementplan'));
      body = {
        'replacementplanFile': '${date[0]}/${date[1]}/${date[2]}/${date[4]}'
      };
    }
  }
  if (update) {
    String defaultUnitplan =
        '{"participant": "5a", "date": "01.01.00", "data": []}';
    String oldUnitplan = Storage.getString(Keys.unitPlan(grade));
    await fetchDataAndSave(url, Keys.unitPlan(grade), defaultUnitplan,
        body: body, onFinished: (bool v) => successfully = v);
    String newUnitPlan = Storage.getString(Keys.unitPlan(grade));
    if (oldUnitplan != null) await checkUnitplanUpdated(oldUnitplan, newUnitPlan);
  }

  // Parse data...
  if (!(temp ?? false)) {
    UnitPlan.days = await fetchDays(grade);

    // Set default selections...
    UnitPlan.setAllSelections();

    // Convert old selection format...
    convertFromOldVerion();
  } else {
    if (onFinished != null) onFinished(successfully);
    return await fetchDays(grade);
  }
  if (onFinished != null) onFinished(successfully);
  return null;
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

/// Returns parsed unit plan...
List<UnitPlanDay> parseDays(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, dynamic>()['data'];
  return parsed.map<UnitPlanDay>((json) => UnitPlanDay.fromJson(json)).toList();
}

/// Returns the unitplan without any replacementplan data
String getFilteredString(String unitPlan) {
  final parsed = json.decode(unitPlan).cast<String, dynamic>()['data'];
  parsed.forEach((day) {
    day['replacementplan'] = null;
    day['lessons'].keys.toList().forEach((lesson) {
      day['lessons'][lesson].forEach((subject) {
        subject['course'] = null;
        subject['changes'] = null;
      });
    });
  });
  return json.encode(parsed);
}

/// Resets the selected subjects when the unitplan changed
Future checkUnitplanUpdated(String version1, String version2) async {
  try {
    if (getFilteredString(version1) != getFilteredString(version2)) {
      Storage.setBool(Keys.unitPlanIsNew, true);
      print('There is a new unitplan, reset old data');
      List<String> keys = Storage.getKeys().toList();
      List<String> keysToReset = keys
          .where((String key) =>
      ((key.startsWith('room-') ||
          key.startsWith('exams') ||
          (key.startsWith('unitPlan') && key
              .split('-')
              .length > 2))))
          .toList();
      keysToReset.forEach((String key) => Storage.remove(key));
      await syncTags();
    }
  } catch (_) {
    print('Failed to compare untiplan versions');
  }
}
