import 'package:flutter/material.dart';

import '../Home/HomePage.dart';
import '../Localizations.dart';
import '../UnitPlan/UnitPlanData.dart' as unitplan;
import 'ReplacementPlanData.dart' as replacementplan;
import 'ReplacementPlanModel.dart';
import 'ReplacementPlanView.dart';

class ReplacementPlanPage extends StatefulWidget {
  @override
  ReplacementPlanPageView createState() => ReplacementPlanPageView();
}

abstract class ReplacementPlanPageState extends State<ReplacementPlanPage>
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
  List<ReplacementPlanDay> days;
  TabController controller;

  @override
  void initState() {
    listener = () => setState(() => null);
    HomePageState.replacementplanUpdatedListeners.add(listener);
    HomePageState.setWeekChangeable(false);
    WidgetsBinding.instance.addPostFrameCallback((a) {
      setState(() {
        days = generateDays(replacementplan.getReplacementPlan());
        weekdays = days.map((day) => day.weekday).toList();
        controller = TabController(vsync: this, length: days.length);
      });
      int day = 0;
      bool over = false;
      int weekday = DateTime
          .now()
          .weekday;
      if (weekday <= 4) {
        if (unitplan.getUnitPlan()[weekday].lessons.length > 0) {
          if (DateTime.now().isAfter(DateTime(DateTime
              .now()
              .year,
              DateTime
                  .now()
                  .month, DateTime
                  .now()
                  .day, 8)
              .add(Duration(
              minutes: [60, 130, 210, 280, 360, 420, 480, 545][unitplan
                  .getUnitPlan()[weekday]
                  .getUserLesseonsCount(
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
      ).add(Duration(days: (over) ? 1 : 0)).isAfter(DateTime(
        (int.parse(days[0].date.split('.')[2]) < 2000)
            ? (int.parse(days[0].date.split('.')[2]) + 2000)
            : (int.parse(days[0].date.split('.')[2])),
        int.parse(days[0].date.split('.')[1]),
        int.parse(days[0].date.split('.')[0]),
      ))) day = 1;
      controller.animateTo(day);
      HomePageState.updateWeek(days[controller.index].weektype);
      controller.addListener(
              () => HomePageState.updateWeek(days[controller.index].weektype));
    });
    super.initState();
  }

  List<ReplacementPlanDay> generateDays(List<ReplacementPlanDay> days) {
    if (days.length == 1) {
      DateTime day = DateTime(
          int.parse(days[0].date.split('.')[2]),
          int.parse(days[0].date.split('.')[1]),
          int.parse(days[0].date.split('.')[0]));
      String weektype = days[0].weektype;
      if (day.weekday >= 5) {
        day = day.add(Duration(days: 8 - day.weekday));
        weektype = weektype == 'A' ? 'B' : 'A';
      } else {
        day = day.add(Duration(days: 1));
      }
      days.add(ReplacementPlanDay(
        date: day.day.toString() +
            '.' +
            day.month.toString() +
            '.' +
            day.year.toString(),
        weekday: AppLocalizations
            .of(context)
            .weekdays[day.weekday - 1],
        weektype: weektype,
        isEmpty: true,
      ));
    }
    return days;
  }

  @override
  void dispose() {
    HomePageState.replacementplanUpdatedListeners.remove(listener);
    super.dispose();
  }
}
