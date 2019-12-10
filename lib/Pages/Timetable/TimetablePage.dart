import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/Downloader/TimetableData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Pages/Timetable/TimetableDayList/TimetableDayListWidget.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Widgets/AppBar.dart';
import 'package:viktoriaflutter/Widgets/TabProxy.dart';

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

  /// All timetable days
  List<TimetableDay> days;

  /// The tab controller to sync day titles with day lists
  TabController _controller;
  List<String> _weekdays;

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
    }

    return weekday;
  }

  @override
  void initState() {
    updatedListener = () => setState(() => days = Data.timetable.days);
    MainFrameState.substitutionPlanUpdatedListeners.add(updatedListener);
    WidgetsBinding.instance.addPostFrameCallback((a) {
      GlobalAppBar.updateTitle(AppLocalizations.of(context).timetable);

      setState(() {
        _weekdays = AppLocalizations.of(context).weekdays;
      });

      // Select correct tab
      _controller = TabController(vsync: this, length: days.length);

      int firstPage = getFirstPageToSelect();
      if (firstPage == -1) {
        firstPage = getCurrentWeekday();
      }
      _controller.animateTo(firstPage);
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
          setState(() => days = Data.timetable.days);
          dataUpdated(context, successfully,
              AppLocalizations.of(context).unitAndSubstitutionPlan);
        });
  }
}
