import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:viktoriaflutter/Utils/Models/CalendarModel.dart';
import 'package:viktoriaflutter/Utils/Models/TimetableModel.dart';
import 'TimetableDayListView.dart';

class TimetableDayList extends StatefulWidget {
  TimetableDay day;
  int dayIndex;

  TimetableDayList({
    Key key,
    @required this.day,
    @required this.dayIndex,
  }) : super(key: key);

  @override
  TimetableDayListView createState() => TimetableDayListView();
}

abstract class TimetableDayListState extends State<TimetableDayList>
    with SingleTickerProviderStateMixin {
  String grade = '';
  TabController tabController;
  bool showWorkGroups = false;
  bool showCalendar = false;
  bool showCafetoria = false;
  bool thisWeek = true;
  PanelController panelController;

  @override
  void initState() {
    panelController = PanelController();
    WidgetsBinding.instance.addPostFrameCallback((a) {
      int weekday = DateTime
          .now()
          .weekday - 1;
      bool over = false;
      if (weekday > 4) {
        weekday = 0;
        thisWeek = false;
      } else if (Timetable.days[weekday].lessons.length > 0) {
        if (DateTime.now().isAfter(DateTime(
          DateTime
              .now()
              .year,
          DateTime
              .now()
              .month,
          DateTime
              .now()
              .day,
          8,
        ).add(Duration(
            minutes: [60, 130, 210, 280, 360, 420, 480, 545][
            Timetable.days[weekday].getUserLessonsCount(
                AppLocalizations
                    .of(context)
                    .freeLesson) -
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
        grade = Storage.getString(Keys.grade);
        showWorkGroups = Storage.get(Keys.showWorkGroupsInTimetable);
        showCalendar = Storage.get(Keys.showCalendarInTimetable);
        showCafetoria = Storage.get(Keys.showCafetoriaInTimetable);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (tabController != null) {
      tabController.dispose();
    }
    super.dispose();
  }

  List<CalendarEvent> getEventsForWeekday(int weekday) {
    DateTime today = DateTime.now();
    DateTime targetDay = today
        .subtract(Duration(days: today.weekday))
        .add(Duration(days: weekday + (!thisWeek ? 7 : 0) + 1));
    return Calendar.events.where((event) {
      try {
        return (event.start.isBefore(targetDay) || event.start == targetDay) &&
          (event.end.isAfter(targetDay) || event.end == targetDay);
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
