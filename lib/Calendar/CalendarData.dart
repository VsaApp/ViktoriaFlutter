import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../Keys.dart';
import '../Network.dart';
import '../Storage.dart';
import 'CalendarModel.dart';

// Download calendar data...
Future download({bool update = true}) async {
  if (update) {
    String url = 'https://api.vsa.2bad2c0.de/calendar/calendar.json?v=' +
        Random().nextInt(99999999).toString();
    await fetchDataAndSave(url, Keys.calendar, '{}');
  }

  // Parse loaded data...
  Calendar.events = await fetchEvents();
}

// Returns the static calendar data...
List<CalendarEvent> getCalendar() {
  return Calendar.events;
}

// Load calendar from preferences...
Future<List<CalendarEvent>> fetchEvents() async {
  return parseEvents(Storage.getString(Keys.calendar));
}

// Returns parse calendar events...
List<CalendarEvent> parseEvents(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed['data']
      .map<CalendarEvent>((json) => CalendarEvent.fromJson(json))
      .toList();
}
