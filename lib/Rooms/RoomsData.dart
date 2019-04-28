import 'dart:async';
import 'dart:convert';

import '../Keys.dart';
import '../Network.dart';
import '../Storage.dart';
import 'RoomsModel.dart';

// Download the unit plan...
Future<Map<String, String>> download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = '/rooms';
    await fetchDataAndSave(url, Keys.rooms, '{}', onFinished: (bool v) => successfully = v);
  }

  // Parse data...
  Rooms.rooms = await fetchRooms();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static rooms...
Map<String, String> getRooms() {
  return Rooms.rooms;
}

// Get rooms from preferences...
Future<Map<String, String>> fetchRooms() async {
  return parseRooms(Storage.getString(Keys.rooms));
}

// Returns parsed rooms...
Map<String, String> parseRooms(String responseBody) {
  final parsed = json.decode(responseBody).cast<String, String>();
  return parsed;
}
