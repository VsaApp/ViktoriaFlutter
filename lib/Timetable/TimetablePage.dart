import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Week.dart';

import 'package:viktoriaflutter/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Timetable/TimetableDayList/TimetableDayListWidget.dart';

/// Page with a sliding page of all timetable days
class TimetablePage extends StatefulWidget {
  @override
  TimetableView createState() => TimetableView();
}

// ignore: public_member_api_docs
class TimetableView extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  /// Timetable updated listener
  Function() updatedListener;

  /// The current A/B week
  bool thisWeek = true;

  /// All timetable days
  List<TimetableDay> days;

  /// The tab controller to sync day titles with day lists
  TabController _controller;

  int _originalWeek;
  List<String> _weekdays;

  /// Sets the week for each day
  void setWeeks() {
    // Get the week number of the shown week...
    final DateTime today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    int weeks = Date.now().getWeekOfYear();
    if (!thisWeek) {
      weeks++;
    }
    final int currentWeek = weeks % 2;

    // Set all days to this week...
    Data.timetable.days.forEach((TimetableDay day) => day.showWeek = weeks % 2);

    // If there are changes for other weeks, set that days to this week...
    final DateTime dateOfMonday = today.add(Duration(
        days: thisWeek ? -today.weekday : DateTime.sunday + 1 - today.weekday));
    for (int i = 0; i < Data.substitutionPlan.days.length; i++) {
      final SubstitutionPlanDay day = Data.substitutionPlan.days[i];
      if (day.week != currentWeek) {
        final DateTime date = day.date;
        for (int j = 0; j < Data.timetable.days.length; j++) {
          final DateTime dateOfDay = dateOfMonday.add(Duration(days: j));
          if (date.isAfter(today) && dateOfDay.weekday <= date.weekday) {
            Data.timetable.days[j - 1 > 0 ? j - 1 : 0].showWeek = day.week;
          } else if (date.isBefore(today) &&
              dateOfDay.weekday >= date.weekday) {
            Data.timetable.days[j].showWeek = day.week;
          }
        }
      }
    }
  }

  /// There is a day with a lesson that still is not selected, go to this day
  int getFirstPageToSelect() {
    for (int i = 0; i < Data.timetable.days.length; i++) {
      final TimetableDay day = Data.timetable.days[i];
      for (int j = 0; j < day.units.length; j++) {
        final TimetableUnit unit = day.units[j];
        if (getSelectedIndex(unit.subjects) == null) {
          return i;
        }
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
    } else if (days[weekday].units.isNotEmpty) {
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
    updatedListener = () => setState(() => days = Data.timetable.days);
    MainFrameState.substitutionPlanUpdatedListeners.add(updatedListener);
    MainFrameState.setWeekChangeable(true);
    WidgetsBinding.instance.addPostFrameCallback((a) {
      setState(() {
        _weekdays = AppLocalizations.of(context)
            .weekdays
            .map((day) => day.substring(0, 2).toUpperCase())
            .toList();
      });

      // Select correct tab
      _controller = TabController(vsync: this, length: days.length);

      int firstPage = getFirstPageToSelect();
      if (firstPage == -1) {
        firstPage = getCurrentWeekday();
      }
      _controller.animateTo(firstPage);
      setWeeks();

      MainFrameState.updateWeek(Data.timetable.days[firstPage].showWeek);
      _controller.addListener(() {
        if (_originalWeek != null) {
          Data.timetable.days[_controller.previousIndex].showWeek =
              _originalWeek;
          _originalWeek = null;
        }
        MainFrameState.updateWeek(
            Data.timetable.days[_controller.index].showWeek);
      });

      // Add week listener...
      MainFrameState.weekChanged = (int week) {
        _originalWeek ??= Data.timetable.days[_controller.index].showWeek;
        if (mounted) {
          setState(
              () => Data.timetable.days[_controller.index].showWeek = week);
        }
      };
    });
    setState(() => days = Data.timetable.days);
    super.initState();
  }

  @override
  void dispose() {
    MainFrameState.substitutionPlanUpdatedListeners.remove(updatedListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty || _weekdays == null) {
      return Container();
    }
    return TabProxy(
        weekdays: _weekdays,
        tabs: days
            .map((day) => TimetableDayList(
                  day: day,
                ))
            .toList(),
        controller: _controller,
        onUpdate: () async {
          bool successfully =
              await TimetableData().download(context) == StatusCodes.success;
          MainFrameState.checkIfTimetableUpdated(context);
          await syncWithTags();
          successfully = await SubstitutionPlanData().download(context) ==
                  StatusCodes.success &&
              successfully;

          Data.substitutionPlan.insert();
          Data.substitutionPlan.updateFilter();
          setWeeks();
          setState(() => days = Data.timetable.days);
          dataUpdated(context, successfully,
              AppLocalizations.of(context).unitAndSubstitutionPlan);
        });
  }
}
