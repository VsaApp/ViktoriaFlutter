import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Network.dart';
import 'CalendarModel.dart';

// Download calendar data...
Future download() async {
  String url = 'https://api.vsa.2bad2c0.de/calendar/calendar.json?v=' +
      Random().nextInt(99999999).toString();
  await fetchDataAndSave(url, Keys.calendar, '{}');

  // Parse loaded data...
  Calendar.events = await fetchEvents();
}

// Returns the static calendar data...
List<CalendarEvent> getCalendar() {
  return Calendar.events;
}

// Load calendar from preferences...
Future<List<CalendarEvent>> fetchEvents() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseEvents(sharedPreferences.getString(Keys.calendar));
}

// Returns parse calendar events...
List<CalendarEvent> parseEvents(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed['data']
      .map<CalendarEvent>((json) => CalendarEvent.fromJson(json))
      .toList();
}
