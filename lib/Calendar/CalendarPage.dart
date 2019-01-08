import 'package:flutter/material.dart';
import 'CalendarData.dart';
import 'CalendarModel.dart';
import 'CalendarDayList/CalendarDayListWidget.dart';

class CalendarPage extends StatefulWidget {
  @override
  CalendarView createState() => CalendarView();
}

class CalendarView extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    List<CalendarEvent> events = getCalendar();
    events = events.where((event) {
      bool ok = true;
      DateTime d1 = DateTime(
          int.parse(event.start.date.split('.')[2]),
          int.parse(event.start.date.split('.')[1]),
          int.parse(event.start.date.split('.')[0]));
      ok = d1.isAfter(DateTime.now());
      if (event.end.date != '' && event.end.date != null) {
        DateTime d2 = DateTime(
            int.parse(event.end.date.split('.')[2]),
            int.parse(event.end.date.split('.')[1]),
            int.parse(event.end.date.split('.')[0]));
        if (!ok) {
          ok = d2.isAfter(DateTime.now());
        }
      }
      return ok;
    }).toList();
    events.sort((a, b) {
      DateTime d1 = DateTime(
          int.parse(a.start.date.split('.')[2]),
          int.parse(a.start.date.split('.')[1]),
          int.parse(a.start.date.split('.')[0]));
      DateTime d2 = DateTime(
          int.parse(b.start.date.split('.')[2]),
          int.parse(b.start.date.split('.')[1]),
          int.parse(b.start.date.split('.')[0]));
      return d1.isAfter(d2) ? 1 : -1;
    });
    return Column(children: <Widget>[CalendarDayList(events: events)]);
  }
}
