import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'CalendarGridItemView.dart';

/// One day in the calendar grid
/// 
/// This item is in the background of the events
class CalendarGridItem extends StatefulWidget {
  /// The date of of this event
  final DateTime date;

  /// If the date is in the main month or only in the preview
  final bool main;

  // ignore: public_member_api_docs
  const CalendarGridItem({
    @required this.date,
    @required this.main,
  }) : super();

  @override
  State<StatefulWidget> createState() => CalendarGridItemView();
}

// ignore: public_member_api_docs
abstract class CalendarGridItemState extends State<CalendarGridItem> {
  /// Checks if the date is the current day
  bool isToday() {
    final DateTime today = DateTime.now();
    return widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;
  }

  /// Check if the date was yesterday
  bool isYesterday() {
    final DateTime today = DateTime.now().add(Duration(days: -1));
    return widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;
  }

  /// Returns all events for the date
  List<CalendarEvent> getEvents() {
    return Data.calendar.events.where((event) {
      return event.start != null &&
          event.end != null &&
          (event.start.isBefore(widget.date) || event.start == widget.date) &&
          (event.end.isAfter(widget.date) || event.end == widget.date);
    }).toList();
  }
}
