import 'package:flutter/material.dart';

import '../CalendarModel.dart';
import 'CalendarGridView.dart';

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
}
