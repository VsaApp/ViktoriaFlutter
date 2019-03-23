import 'dart:async';
import 'dart:convert';

import '../Keys.dart';
import '../Network.dart';
import '../Storage.dart';
import 'RoomsModel.dart';

// Download the unit plan...
Future<Map<String, String>> download() async {
  // Get the selected grade...
  String url = 'https://api.vsa.2bad2c0.de/rooms';
  await fetchDataAndSave(url, Keys.rooms, '{}');

  // Parse data...
  Rooms.rooms = await fetchRooms();
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
