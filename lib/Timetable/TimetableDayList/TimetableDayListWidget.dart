import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Timetable/TimetableDayList/TimetableDayListView.dart';

/// A list of all units of one day
class TimetableDayList extends StatefulWidget {
  /// The timetable day to show
  final TimetableDay day;

  // ignore: public_member_api_docs
  const TimetableDayList({
    @required this.day,
    Key key,
  }) : super(key: key);

  @override
  TimetableDayListView createState() => TimetableDayListView();
}

// ignore: public_member_api_docs
abstract class TimetableDayListState extends State<TimetableDayList>
    with SingleTickerProviderStateMixin {
  /// Defines if the work groups should be shown
  bool showWorkGroups = false;

  /// Defines if the calendar should be shown
  bool showCalendar = false;

  /// Defines if the cafetoria should be shown
  bool showCafetoria = false;

  /// Defines the A/B week of this day
  bool thisWeek = true;

  /// Panel controller for the sliding up panel
  PanelController panelController;

  @override
  void initState() {
    panelController = PanelController();
    WidgetsBinding.instance.addPostFrameCallback((a) {
      int weekday = DateTime.now().weekday - 1;
      bool over = false;
      if (weekday > 4) {
        weekday = 0;
        thisWeek = false;
      } else if (Data.timetable.days[weekday].units.isNotEmpty) {
        if (DateTime.now().isAfter(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          8,
        ).add(Duration(
            minutes: [60, 130, 210, 280, 360, 420, 480, 545][
                Data.timetable.days[weekday].getUserLessonsCount(
                        AppLocalizations.of(context).freeLesson) -
                    1])))) {
          over = true;
        }
      }
      if (over) {
        weekday++;
      }
      // If weekend select Monday
      if (weekday > 4) {
        weekday = 0;
        thisWeek = false;
      }
      setState(() {
        showWorkGroups = Storage.get(Keys.showWorkGroupsInTimetable);
        showCalendar = Storage.get(Keys.showCalendarInTimetable);
        showCafetoria = Storage.get(Keys.showCafetoriaInTimetable);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Returns all calendar events for a given [weekday]
  List<CalendarEvent> getEventsForWeekday(int weekday) {
    final DateTime today = DateTime.now();
    final DateTime targetDay = today
        .subtract(Duration(days: today.weekday))
        .add(Duration(days: weekday + (!thisWeek ? 7 : 0) + 1));
    return Data.calendar.events.where((event) {
      try {
        return (event.start.isBefore(targetDay) || event.start == targetDay) &&
            (event.end.isAfter(targetDay) || event.end == targetDay);
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
