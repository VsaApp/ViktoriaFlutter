import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'CalendarModel.dart';

// Download calendar data...
Future download({bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = '/calendar/calendar.json?v=' +
        Random().nextInt(99999999).toString();
    await fetchDataAndSave(url, Keys.calendar, '{}', onFinished: (v) => successfully = v);
  }

  // Parse loaded data...
  Calendar.events = await fetchEvents();
  if (onFinished != null) onFinished(successfully);
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
