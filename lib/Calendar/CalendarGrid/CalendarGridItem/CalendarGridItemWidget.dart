import 'package:flutter/material.dart';

import '../../CalendarModel.dart';
import 'CalendarGridItemView.dart';

class CalendarGridItem extends StatefulWidget {
  final DateTime date;
  final bool main;

  CalendarGridItem({
    @required this.date,
    @required this.main,
  }) : super();

  @override
  State<StatefulWidget> createState() => CalendarGridItemView();
}

abstract class CalendarGridItemState extends State<CalendarGridItem> {
  List<CalendarEvent> getEvents() {
    return Calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(widget.date) || event.start == widget.date) &&
          (event.end.isAfter(widget.date) || event.end == widget.date);
    }).toList();
  }
}
