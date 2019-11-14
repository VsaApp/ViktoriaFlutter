import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

// Download the timetable...
Future<Updates> download(
    {bool update = true, Function(int statusCode) onFinished}) async {
  if (!update) {
    if (onFinished != null) onFinished(StatusCodes.success);
    Data.updates = fetchUpdates();
    return Data.updates;
  }

  // Get response
  final response = await fetch(Urls.updates);
  int statusCode = response.statusCode;

  if (statusCode != StatusCodes.success) {
    if (onFinished != null) onFinished(statusCode);
    return null;
  }

  // Parse data...
  Data.updates = parseUpdates(response.body);
  if (onFinished != null) onFinished(statusCode);
  return parseUpdates(response.body);
}

/// Returns the static updates...
Updates getUpdates({loaded = true}) {
  return loaded ? Data.updates : fetchUpdates();
}

void saveUpdates() {
  Storage.setString(Keys.updates, Data.updates.toJson());
}

/// Get updates from preferences...
Updates fetchUpdates() {
  return parseUpdates(Storage.getString(Keys.updates) ?? _defaultValue);
}

/// Returns parsed updates...
Updates parseUpdates(String responseBody) {
  final parsed = json.decode(responseBody);
  return Updates.fromJson(parsed);
}

String get _defaultValue => Updates(
        timetable: DateTime.fromMillisecondsSinceEpoch(0),
        substitutionPlan: DateTime.fromMillisecondsSinceEpoch(0),
        cafetoria: DateTime.fromMillisecondsSinceEpoch(0),
        calendar: DateTime.fromMillisecondsSinceEpoch(0),
        teachers: DateTime.fromMillisecondsSinceEpoch(0),
        workgroups: DateTime.fromMillisecondsSinceEpoch(0),
        rooms: DateTime.fromMillisecondsSinceEpoch(0),
        subjects: DateTime.fromMillisecondsSinceEpoch(0),
        minAppLevel: 1,
        grade: '')
    .toJson();
