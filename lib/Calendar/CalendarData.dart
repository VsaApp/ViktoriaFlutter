import 'dart:async';
import 'dart:convert';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

// Download calendar data...
Future download(
    {bool update = true, Function(bool successfully) onFinished}) async {
  bool successfully;
  if (update) {
    String url = Urls.calendar;
    await fetchDataAndSave(
      url,
      Keys.calendar,
      '{"years": [], "data": []}',
      onFinished: (v) => successfully = v == StatusCodes.success,
    );
  }

  // Parse loaded data...
  Data.calendar = fetchCalendar();
  if (onFinished != null) onFinished(successfully);
}

// Returns the static calendar data...
List<CalendarEvent> getCalendarEvents() {
  return Data.calendar.events;
}

// Load calendar from preferences...
Calendar fetchCalendar() {
  return parseCalendar(Storage.getString(Keys.calendar));
}

// Returns parse calendar events...
Calendar parseCalendar(String responseBody) {
  final parsed = json.decode(responseBody);
  return Calendar.fromJson(parsed);
}
