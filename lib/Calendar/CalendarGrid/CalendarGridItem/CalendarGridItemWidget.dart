import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models/CalendarModel.dart';
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

  bool isToday() {
    DateTime today = DateTime.now();
    return widget.date.year == today.year && widget.date.month == today.month && widget.date.day == today.day;
  }

  bool isYesterday() {
    DateTime today = DateTime.now().add(Duration(days: -1));
    return widget.date.year == today.year && widget.date.month == today.month && widget.date.day == today.day;
  }

  List<CalendarEvent> getEvents() {
    return Calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(widget.date) || event.start == widget.date) &&
          (event.end.isAfter(widget.date) || event.end == widget.date);
    }).toList();
  }
}
