import 'package:flutter/material.dart';

import '../Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../Timetable/TimetableData.dart' as timetable;
import 'SubstitutionPlanData.dart' as substitutionPlan;
import 'package:viktoriaflutter/Utils/Models.dart';
import 'SubstitutionPlanView.dart';

class SubstitutionPlanPage extends StatefulWidget {
  @override
  SubstitutionPlanPageView createState() => SubstitutionPlanPageView();
}

abstract class SubstitutionPlanPageState extends State<SubstitutionPlanPage>
    with SingleTickerProviderStateMixin {
  Function() listener;
  static List<String> grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];

  List<String> weekdays;
  List<SubstitutionPlanDay> days;
  TabController controller;

  @override
  void initState() {
    listener = initDays;
    HomePageState.substitutionPlanUpdatedListeners.add(listener);
    HomePageState.setWeekChangeable(false);
    initDays();
    super.initState();
  }

  void initDays() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
        setState(() {
          days = generateDays(substitutionPlan.getSubstitutionPlan());
          weekdays = days.map((day) => AppLocalizations.of(context).weekdays[day.date.weekday - 1]).toList();
          controller = TabController(vsync: this, length: days.length);
        });
        int day = 0;
        bool over = false;
        int weekday = DateTime
            .now()
            .weekday - 1;
        if (weekday <= 4) {
          if (timetable.getTimetable()[weekday].units.length > 0) {
            if (DateTime.now().isAfter(DateTime(DateTime
                .now()
                .year,
                DateTime
                    .now()
                    .month, DateTime
                    .now()
                    .day, 8)
                .add(Duration(
                minutes: [60, 130, 210, 280, 360, 420, 480, 545][timetable
                    .getTimetable()[weekday]
                    .getUserLessonsCount(
                    AppLocalizations
                        .of(context)
                        .freeLesson) -
                    1])))) {
              over = true;
            }
          }
        }

        // If the first day is passed, select the next day...
        if (DateTime(
          DateTime
              .now()
              .year,
          DateTime
              .now()
              .month,
          DateTime
              .now()
              .day,
        ).add(Duration(days: (over) ? 1 : 0)).isAfter(days[0].date)) day = 1;
        controller.animateTo(day);
        HomePageState.updateWeek(days[controller.index].week);
        controller.addListener(
                () => HomePageState.updateWeek(days[controller.index].week));
      });
    }

  List<SubstitutionPlanDay> generateDays(List<SubstitutionPlanDay> days) {
    if (days.length == 1) {
      DateTime day = days[0].date;
      int weektype = days[0].week;
      if (day.weekday >= 5) {
        day = day.add(Duration(days: 8 - day.weekday));
        weektype = weektype == 0 ? 1 : 0;
      } else {
        day = day.add(Duration(days: 1));
      }
      days.add(SubstitutionPlanDay(
        date: day,
        week: weektype,
        updated: DateTime.now(),
        data: {},
        unparsed: {},
        isEmpty: true,
      ));
    }
    return days;
  }

  @override
  void dispose() {
    HomePageState.substitutionPlanUpdatedListeners.remove(listener);
    super.dispose();
  }
}
