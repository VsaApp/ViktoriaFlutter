import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

// Download the timetable...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    await fetchDataAndSave(Urls.rooms, Keys.rooms, '{}', onFinished: (int v) => successfully = v == 200);
  }

  // Parse data...
  Data.rooms = fetchRooms();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static rooms...
Map<String, String> getRooms() {
  return Data.rooms;
}

// Get rooms from preferences...
Map<String, String> fetchRooms() {
  return parseRooms(Storage.getString(Keys.rooms));
}

// Returns parsed rooms...
Map<String, String> parseRooms(String responseBody) {
  return json.decode(responseBody).cast<String, String>();
}
