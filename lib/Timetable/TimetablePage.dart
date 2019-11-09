import 'package:flutter/material.dart';

import '../Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../SubstitutionPlan/SubstitutionPlanData.dart' as substitutionPlan;
import '../SubstitutionPlan/SubstitutionPlanModel.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'TimetableData.dart' as timetable;
import 'TimetableDayList/TimetableDayListWidget.dart';
import 'TimetableModel.dart';

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
  String originalWeek;
  List<String> weekdays;

  void setWeeks() {
    // Get the week number of the shown week...
    DateTime today = DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day + 1);
    DateTime startOfYear = DateTime(today.year, 1, 1, 0, 0);
    int firstMonday = startOfYear.weekday;
    int daysInFirstWeek = 8 - firstMonday;
    Duration diff = today.difference(startOfYear);
    int weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
    if (daysInFirstWeek > 3) weeks++;
    if (!thisWeek) weeks++;
    String currentWeek = weeks % 2 == 0 ? 'A' : 'B';

    // Set all days to this week...
    Timetable.days.forEach((TimetableDay day) => day.showWeek = currentWeek);

    // If there are changes for other weeks, set that days to this week...
    DateTime dateOfMonday = today.add(Duration(
        days: thisWeek ? -today.weekday : DateTime.sunday + 1 - today.weekday));
    for (int i = 0; i < SubstitutionPlan.days.length; i++) {
      SubstitutionPlanDay day = SubstitutionPlan.days[i];
      if (day.weektype != currentWeek) {
        DateTime date = DateTime(
            int.parse(day.date.split('.')[2]),
            int.parse(day.date.split('.')[1]),
            int.parse(day.date.split('.')[0]));
        for (int j = 0; j < Timetable.days.length; j++) {
          DateTime dateOfDay = dateOfMonday.add(Duration(days: j));
          if (date.isAfter(today) && dateOfDay.weekday <= date.weekday)
            Timetable.days[j - 1 > 0 ? j - 1 : 0].showWeek = day.weektype;
          else if (date.isBefore(today) && dateOfDay.weekday >= date.weekday)
            Timetable.days[j].showWeek = day.weektype;
        }
      }
    }
  }

  int getFirstPageToSelect() {
    for (int i = 0; i < Timetable.days.length; i++) {
      TimetableDay day = Timetable.days[i];
      for (int j = 0; j < day.lessons.length; j++) {
        TimetableLesson lesson = day.lessons[j];
        if (getSelectedIndex(lesson.subjects, i, j) == null) return i;
      }
    }
    return -1;
  }

  int getCurrentWeekday() {
    int weekday = DateTime
        .now()
        .weekday - 1;
    bool over = false;
    if (weekday > 4) {
      weekday = 0;
      thisWeek = false;
    } else if (days[weekday].lessons.length > 0) {
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
          minutes: [60, 130, 210, 280, 360, 420, 480, 545][days[weekday]
              .getUserLesseonsCount(
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

    return weekday;
  }

  @override
  void initState() {
    listener = () => setState(() => days = timetable.getTimetable());
    HomePageState.substitutionPlanUpdatedListeners.add(listener);
    HomePageState.setWeekChangeable(true);
    WidgetsBinding.instance.addPostFrameCallback((a) {
      setState(() {
        weekdays = AppLocalizations
            .of(context)
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

      HomePageState.updateWeek(Timetable.days[firstPage].showWeek);
      controller.addListener(() {
        if (originalWeek != null) {
          Timetable.days[controller.previousIndex].showWeek = originalWeek;
          originalWeek = null;
        }
        HomePageState.updateWeek(Timetable.days[controller.index].showWeek);
      });

      // Add week listener...
      HomePageState.weekChanged = (String week) {
        if (originalWeek == null)
          originalWeek = Timetable.days[controller.index].showWeek;
        if (mounted)
          setState(() => Timetable.days[controller.index].showWeek = week);
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
            .map((day) =>
            TimetableDayList(
              day: day,
              dayIndex: days.indexOf(day),
            ))
            .toList(),
        controller: controller,
        onUpdate: () async {
          await timetable.download(Storage.getString(Keys.grade), false,
              onFinished: (successfully) {
                dataUpdated(context, successfully,
                    AppLocalizations
                        .of(context)
                        .unitAndSubstitutionPlan);
                HomePageState.checkIfTimetableUpdated(context);
          });
          substitutionPlan.load(timetable.getTimetable(), false);
          setWeeks();
          setState(() => days = timetable.getTimetable());
        });
  }
}
