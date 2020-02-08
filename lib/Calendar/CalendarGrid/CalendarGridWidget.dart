import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'CalendarGridEvent/CalendarGridEventWidget.dart';
import 'CalendarGridView.dart';

/// A grid with a month overview about all events
class CalendarGrid extends StatefulWidget {
  /// The events for this month
  final List<CalendarEvent> events;

  // ignore: public_member_api_docs
  const CalendarGrid({
    @required this.events,
  }) : super();

  @override
  CalendarGridView createState() => CalendarGridView();
}

// ignore: public_member_api_docs
abstract class CalendarGridState extends State<CalendarGrid>
    with SingleTickerProviderStateMixin {
  /// The first event in the month
  DateTime firstEvent;

  /// The last event in the month
  DateTime lastEvent;

  /// The tab controller to slide between the months
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
    widget.events.sort((a, b) => a.start.millisecondsSinceEpoch
        .compareTo(b.start.millisecondsSinceEpoch));
    firstEvent = widget.events[0].start;
    controller = TabController(
      length: lastEvent.month -
          firstEvent.month +
          1 +
          (lastEvent.year - firstEvent.year) * 12,
      vsync: this,
    );
    super.initState();
  }

  /// Returns the number of days in a given month
  int daysInMonth(int monthNum, int year) {
    DateTime date = DateTime(year, monthNum + 2);
    date = date.add(Duration(days: -1));
    return date.day;
  }

  /// Returns the number of days that the event should be shown in the given week
  int getDayOfWeek(DateTime monday, DateTime sunday, DateTime date) {
    if (date.isBefore(monday)) {
      return 0;
    }
    if (date.isAfter(sunday)) {
      return 6;
    }
    return date.weekday - 1;
  }

  /// Creates all views for the events
  List<Positioned> getEventViewsForWeek(
      DateTime monday, DateTime sunday, double width, double height) {
    return getEventsForWeek(monday, sunday)
        .map((event) {
          final List<Positioned> lines = [];
          // Show a point in the corner top right when...
          // ... the hight is too small to show an event
          // ... the hight is too small to show two events
          // ... there are more than 2 events
          if (height / 6 < 40 ||
              (height / 6 < 70 &&
                  (getEventsForDate(event.start)
                              .where((e) =>
                                  Data.calendar.events.indexOf(e) <
                                  Data.calendar.events.indexOf(event))
                              .length +
                          1) >
                      1) ||
              (getEventsForDate(event.start)
                          .where((e) =>
                              Data.calendar.events.indexOf(e) <
                              Data.calendar.events.indexOf(event))
                          .length +
                      1) >
                  2) {
            for (int i = getDayOfWeek(monday, sunday, event.start);
                i <= getDayOfWeek(monday, sunday, event.end);
                i++) {
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
                  )));
            }
          } else {
            lines.add(Positioned(
                top: 25.0 *
                    (getEventsForDate(event.start)
                            .where((e) =>
                                Data.calendar.events.indexOf(e) <
                                Data.calendar.events.indexOf(event))
                            .length +
                        1),
                left: 3 + getDayOfWeek(monday, sunday, event.start) * width / 7,
                child: SizedBox(
                  width: (getDayOfWeek(monday, sunday, event.end) -
                              getDayOfWeek(monday, sunday, event.start) +
                              1) *
                          width /
                          7 -
                      6,
                  child: CalendarGridEvent(event: event),
                )));
          }
          return lines;
        })
        .toList()
        .expand((x) => x)
        .toList();
  }

  /// Returns all events for a given date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return Data.calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(date) || event.start == date) &&
          (event.end.isAfter(date) || event.end == date);
    }).toList();
  }

  /// Returns all events for a given week
  List<CalendarEvent> getEventsForWeek(DateTime monday, DateTime sunday) {
    return Data.calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(sunday) || event.start == sunday) &&
          (event.end.isAfter(monday) || event.end == monday);
    }).toList();
  }
}
