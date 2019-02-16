import 'package:flutter/material.dart';

import 'CalendarDayList/CalendarDayListWidget.dart';

class CalendarPage extends StatefulWidget {
  @override
  CalendarView createState() => CalendarView();
}

class CalendarView extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[CalendarDayList()]);
  }
}
