import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../models/Calendar.dart';

Future download() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    String _url = 'https://api.vsa.2bad2c0.de/calendar/calendar.json?v=' +
        new Random().nextInt(99999999).toString();
    print(_url);
    final response = await http.Client().get(_url);
    sharedPreferences.setString(Keys.calendar, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.calendar) == null) {
      sharedPreferences.setString(Keys.calendar, '{}');
    }
  }

  Calendar.days = await fetchEvents();
}

List<CalendarEvent> getCalendar() {
  return Calendar.days;
}

Future<List<CalendarEvent>> fetchEvents() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseEvents(sharedPreferences.getString(Keys.calendar));
}

List<CalendarEvent> parseEvents(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed['data']
      .map<CalendarEvent>((json) => CalendarEvent.fromJson(json))
      .toList();
}
