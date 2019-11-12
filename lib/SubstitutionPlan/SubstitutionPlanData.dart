import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// Downloads the substitution plan
///
/// If temp is true, the downloaded timetable will be returned and not set in the static class (Default temp is false).
///
/// If update is true, the timetable will be downloaded from the server and if not it only would be loaded from the storage.
Future<SubstitutionPlan> download(
    {bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;

  if (update) {
    // Default timetable (Only for download errors)
    String defaultSubstitutionPlan = json.encode([]);
    await fetchDataAndSave(
      Urls.substitutionPlan,
      Keys.substitutionPlan,
      defaultSubstitutionPlan,
      onFinished: (int v) => successfully = v == 200,
    );
  }

  // Parse data...
  Data.substitutionPlan = fetchSubstitutionPlan();

  if (onFinished != null) onFinished(successfully);
  return null;
}

// Returns the static substitution plan...
List<SubstitutionPlanDay> getSubstitutionPlan() {
  return Data.substitutionPlan.days;
}

/// Get timetable from preferences...
SubstitutionPlan fetchSubstitutionPlan() {
  return parseSubstitutionPlan(Storage.getString(Keys.substitutionPlan));
}

/// Returns parsed timetable...
SubstitutionPlan parseSubstitutionPlan(String responseBody) {
  final parsed = json.decode(responseBody);
  return SubstitutionPlan(
    days: parsed
        .map<SubstitutionPlanDay>((day) => SubstitutionPlanDay.fromJson(day))
        .toList(),
  );
}
