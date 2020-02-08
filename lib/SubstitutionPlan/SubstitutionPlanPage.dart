import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanView.dart';
import 'package:viktoriaflutter/Utils/Week.dart';

/// Sliding page for all substitution plan days
class SubstitutionPlanPage extends StatefulWidget {
  @override
  SubstitutionPlanPageView createState() => SubstitutionPlanPageView();
}

// ignore: public_member_api_docs
abstract class SubstitutionPlanPageState extends State<SubstitutionPlanPage>
    with SingleTickerProviderStateMixin {
  /// The substitution plan updated listener
  Function() updatesListener;

  /// List of grade to show a list for switching
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

  /// The weekday name in the correct language fot the tab titles
  List<String> weekdays;

  /// All substitution plan days
  List<SubstitutionPlanDay> days;

  /// The tab controller to sync tabs and swipe pages
  TabController controller;

  @override
  void initState() {
    updatesListener = initDays;
    HomePageState.substitutionPlanUpdatedListeners.add(updatesListener);
    initDays();
    super.initState();
  }

  /// Initialize the substitution plan days
  ///
  /// Sort them by date and in some cases add an empty one to inform the user about a missing day
  void initDays() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
      setState(() {
        days = generateDays(Data.substitutionPlan.days);
        weekdays = days
            .map((day) =>
                AppLocalizations.of(context).weekdays[day.date.weekday - 1])
            .toList();
        controller = TabController(vsync: this, length: days.length);
      });
      int day = 0;
      bool over = false;
      final int weekday = DateTime.now().weekday - 1;
      if (weekday <= 4) {
        if (Data.timetable.days[weekday].units.isNotEmpty) {
          if (DateTime.now().isAfter(DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day, 8)
              .add(Duration(
                  minutes: [60, 130, 210, 280, 360, 420, 480, 545][
                      Data.timetable.days[weekday].getUserLessonsCount(
                              AppLocalizations.of(context).freeLesson) -
                          1])))) {
            over = true;
          }
        }
      }

      // If the first day is passed, select the next day...
      if (days.length >= 2) {
        if (DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).add(Duration(days: over ? 1 : 0)).isAfter(days[0].date)) {
          day = 1;
        }
      }
      controller.animateTo(day);
      HomePageState.updateWeek(days[controller.index].week);
      controller.addListener(
          () => HomePageState.updateWeek(days[controller.index].week));
    });
  }

  /// Adds a empty day if there is only one
  List<SubstitutionPlanDay> generateDays(List<SubstitutionPlanDay> days) {
    // Add days until the length is 2
    for (int i = days.length; i < 2; i++) {
      DateTime day = days.isNotEmpty ? days[i - 1].date : DateTime.now();
      int weektype =
          days.isNotEmpty ? days[i - 1].week : Date.now().getWeekOfYear();
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
    HomePageState.substitutionPlanUpdatedListeners.remove(updatesListener);
    super.dispose();
  }
}
