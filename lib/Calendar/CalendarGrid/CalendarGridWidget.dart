import 'package:flutter/material.dart';

import '../CalendarModel.dart';
import 'CalendarGridView.dart';
import 'CalendarGridEvent/CalendarGridEventWidget.dart';

class CalendarGrid extends StatefulWidget {
  final List<CalendarEvent> events;

  CalendarGrid({
    @required this.events,
  }) : super();

  @override
  CalendarGridView createState() => CalendarGridView();
}

abstract class CalendarGridState extends State<CalendarGrid>
    with SingleTickerProviderStateMixin {
  CalendarGridState({@required events}) : super();
  DateTime firstEvent;
  DateTime lastEvent;
  TabController controller;

  @override
  void initState() {
    widget.events.sort((a, b) {
      if (b.end == null) {
        return 1;
      }
      if (a.end == null) {
        return 1;
      }
      return b.end.millisecondsSinceEpoch
          .compareTo(a.end.millisecondsSinceEpoch);
    });
    lastEvent = widget.events[0].end;
    widget.events.sort((a, b) =>
        a.start.millisecondsSinceEpoch
            .compareTo(b.start.millisecondsSinceEpoch));
    firstEvent = widget.events[0].start;
    controller = TabController(
      length: lastEvent.month - firstEvent.month + 1,
      vsync: this,
    );
    super.initState();
  }

  daysInMonth(int monthNum, int year) {
    List<int> monthLength = List(12);

    monthLength[0] = 31;
    monthLength[1] = leapYear(year) ? 29 : 28;
    monthLength[2] = 31;
    monthLength[3] = 30;
    monthLength[4] = 31;
    monthLength[5] = 30;
    monthLength[6] = 31;
    monthLength[7] = 31;
    monthLength[8] = 30;
    monthLength[9] = 31;
    monthLength[10] = 30;
    monthLength[11] = 31;

    return monthLength[monthNum];
  }

  leapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true)
      leapYear = false;
    else if (year % 4 == 0) leapYear = true;

    return leapYear;
  }

  int getDayOfWeek(DateTime monday, DateTime sunday, DateTime date) {
    if (date.isBefore(monday)) return 0;
    if (date.isAfter(sunday)) return 6;
    return date.weekday - 1;
  }

  List<Positioned> getEventViewsForWeek(DateTime monday, DateTime sunday, double width, double height) {
    List<Positioned> views = getEventsForWeek(monday, sunday).map((event) {
      List<Positioned> lines = [];
      // Show a point in the corner top right when...
      // ... the hight is too small to show an event
      // ... the hight is too small to show two events
      // ... there are more than 2 events
      if (height / 6 < 40 || (height / 6 < 70 && (getEventsForDate(event.start).where((e) => Calendar.events.indexOf(e) < Calendar.events.indexOf(event)).length + 1) > 1) || (getEventsForDate(event.start).where((e) => Calendar.events.indexOf(e) < Calendar.events.indexOf(event)).length + 1) > 2) {
        for (int i = getDayOfWeek(monday, sunday, event.start); i <= getDayOfWeek(monday, sunday, event.end); i++) {
          lines.add(Positioned(
            top: 3,
            right: 3.0 + width / 7 * (6 - i),
            child: SizedBox(
              height: 10,
              width: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ));
        }
      }
      else lines.add(Positioned(
        top:  25.0 * (getEventsForDate(event.start).where((e) => Calendar.events.indexOf(e) < Calendar.events.indexOf(event)).length + 1),
        left: 3 + getDayOfWeek(monday, sunday, event.start) * width / 7,
        child: SizedBox(
          width: (getDayOfWeek(monday, sunday, event.end) - getDayOfWeek(monday, sunday, event.start) + 1) * width / 7 - 6,
          child: CalendarGridEvent(event: event),
        )
      ));
      return lines;
    }).toList().expand((x) => x).toList();
    return views;
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return Calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(date) || event.start == date) &&
          (event.end.isAfter(date) || event.end == date);
    }).toList();
  }

  List<CalendarEvent> getEventsForWeek(DateTime monday, DateTime sunday) {
    return Calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(sunday) || event.start == sunday) &&
          (event.end.isAfter(monday) || event.end == monday);
    }).toList();
  }
}
