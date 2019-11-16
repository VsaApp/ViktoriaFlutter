import 'dart:async';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Week.dart';

import '../Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'TimetableData.dart' as timetable;
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanData.dart'
    as substitutionPlan;
import 'TimetableDayList/TimetableDayListWidget.dart';

class TimetablePage extends StatefulWidget {
  @override
  TimetableView createState() => TimetableView();
}

class TimetableView extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  Function() listener;
  bool thisWeek = true;
  List<TimetableDay> days;
  TabController controller;
  int originalWeek;
  List<String> weekdays;

  /// Sets the week for each day
  void setWeeks() {
    // Get the week number of the shown week...
    DateTime today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    int weeks = Date.now().getWeekOfYear();
    if (!thisWeek) weeks++;
    int currentWeek = weeks % 2;

    // Set all days to this week...
    Data.timetable.days.forEach((TimetableDay day) => day.showWeek = weeks % 2);

    // If there are changes for other weeks, set that days to this week...
    DateTime dateOfMonday = today.add(Duration(
        days: thisWeek ? -today.weekday : DateTime.sunday + 1 - today.weekday));
    for (int i = 0; i < Data.substitutionPlan.days.length; i++) {
      SubstitutionPlanDay day = Data.substitutionPlan.days[i];
      if (day.week != currentWeek) {
        DateTime date = day.date;
        for (int j = 0; j < Data.timetable.days.length; j++) {
          DateTime dateOfDay = dateOfMonday.add(Duration(days: j));
          if (date.isAfter(today) && dateOfDay.weekday <= date.weekday)
            Data.timetable.days[j - 1 > 0 ? j - 1 : 0].showWeek = day.week;
          else if (date.isBefore(today) && dateOfDay.weekday >= date.weekday)
            Data.timetable.days[j].showWeek = day.week;
        }
      }
    }
  }

  /// There is a day with a lesson that still is not selected, go to this day
  int getFirstPageToSelect() {
    for (int i = 0; i < Data.timetable.days.length; i++) {
      TimetableDay day = Data.timetable.days[i];
      for (int j = 0; j < day.units.length; j++) {
        TimetableUnit unit = day.units[j];
        if (getSelectedIndex(unit.subjects) == null) return i;
      }
    }
    return -1;
  }

  /// Returns the index of the current school day
  int getCurrentWeekday() {
    int weekday = DateTime.now().weekday - 1;
    bool over = false;
    if (weekday > 4) {
      weekday = 0;
      thisWeek = false;
    } else if (days[weekday].units.length > 0) {
      if (DateTime.now().isAfter(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
      ).add(Duration(
          minutes: [60, 130, 210, 280, 360, 420, 480, 545][days[weekday]
                  .getUserLessonsCount(
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

    return weekday;
  }

  @override
  void initState() {
    listener = () => setState(() => days = timetable.getTimetable());
    HomePageState.substitutionPlanUpdatedListeners.add(listener);
    HomePageState.setWeekChangeable(true);
    WidgetsBinding.instance.addPostFrameCallback((a) {
      setState(() {
        weekdays = AppLocalizations.of(context)
            .weekdays
            .map((day) => day.substring(0, 2).toUpperCase())
            .toList();
      });

      // Select correct tab
      controller = TabController(vsync: this, length: days.length);

      int firstPage = getFirstPageToSelect();
      if (firstPage == -1) firstPage = getCurrentWeekday();
      controller.animateTo(firstPage);
      setWeeks();

      HomePageState.updateWeek(Data.timetable.days[firstPage].showWeek);
      controller.addListener(() {
        if (originalWeek != null) {
          Data.timetable.days[controller.previousIndex].showWeek = originalWeek;
          originalWeek = null;
        }
        HomePageState.updateWeek(
            Data.timetable.days[controller.index].showWeek);
      });

      // Add week listener...
      HomePageState.weekChanged = (int week) {
        if (originalWeek == null)
          originalWeek = Data.timetable.days[controller.index].showWeek;
        if (mounted)
          setState(() => Data.timetable.days[controller.index].showWeek = week);
      };
    });
    setState(() => days = timetable.getTimetable());
    super.initState();
  }

  @override
  void dispose() {
    HomePageState.substitutionPlanUpdatedListeners.remove(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (days.length == 0 || weekdays == null) {
      return Container();
    }
    return TabProxy(
        weekdays: weekdays,
        tabs: days
            .map((day) => TimetableDayList(
                  day: day,
                  dayIndex: days.indexOf(day),
                ))
            .toList(),
        controller: controller,
        onUpdate: () async {
          Completer<bool> completer = Completer<bool>();
          await timetable.download(false, onFinished: (bool successfully) {
            completer.complete(successfully);
            HomePageState.checkIfTimetableUpdated(context);
          });
          await syncWithTags();
          await substitutionPlan.download();

          Data.substitutionPlan.insert();
          Data.substitutionPlan.updateFilter();
          setWeeks();
          setState(() => days = timetable.getTimetable());
          dataUpdated(context, await completer.future,
              AppLocalizations.of(context).unitAndSubstitutionPlan);
        });
  }
}
