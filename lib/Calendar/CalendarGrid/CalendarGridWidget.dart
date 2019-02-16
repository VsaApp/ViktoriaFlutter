import 'package:flutter/material.dart';

import '../CalendarModel.dart';
import 'CalendarGridView.dart';

class CalendarGridWidget extends StatefulWidget {
  @override
  CalendarGridView createState() => CalendarGridView();
}

abstract class CalendarGridState extends State<CalendarGridWidget> {
  List<CalendarEvent> events;

  CalendarGridState({@required events}) : super();
}
