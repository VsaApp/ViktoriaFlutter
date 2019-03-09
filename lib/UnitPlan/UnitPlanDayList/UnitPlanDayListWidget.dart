import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Calendar/CalendarModel.dart';
import '../../Keys.dart';
import '../../Localizations.dart';
import '../../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../../UnitPlan/UnitPlanData.dart' as unitplan;
import '../UnitPlanModel.dart';
import 'UnitPlanDayListView.dart';

class UnitPlanDayList extends StatefulWidget {
  List<UnitPlanDay> days;

  UnitPlanDayList({Key key, this.days}) : super(key: key);

  @override
  UnitPlanDayListView createState() => UnitPlanDayListView();
}

abstract class UnitPlanDayListState extends State<UnitPlanDayList>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  String grade = '';
  TabController tabController;
  bool nextWeek = false;
  bool showWorkGroups = false;
  bool showCalendar = false;
  bool showCafetoria = false;

  Future update() async {
    await unitplan.download(sharedPreferences.getString(Keys.grade), false);
    await replacementplan.load(unitplan.getUnitPlan(), false);
    setState(() => widget.days = unitplan.getUnitPlan());
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      sharedPreferences = instance;
      setState(() {
        grade = sharedPreferences.getString(Keys.grade);
        showWorkGroups = sharedPreferences.get(Keys.showWorkGroupsInUnitPlan);
        showCalendar = sharedPreferences.get(Keys.showCalendarInUnitPlan);
        showCafetoria = sharedPreferences.get(Keys.showCafetoriaInUnitPlan);
      });
      // Select correct tab
      tabController = TabController(vsync: this, length: widget.days.length);
      int weekday = DateTime.now().weekday - 1;
      bool over = false;
      // If weekend select Monday
      if (weekday > 4) {
        weekday = 0;
      } else if (widget.days[weekday].lessons.length > 0) {
        if (DateTime.now().isAfter(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          8,
        ).add(Duration(
            minutes: [60, 130, 210, 280, 360, 420, 480, 545][
                widget.days[weekday].getUserLesseonsCount(sharedPreferences,
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
        nextWeek = true;
      }
      tabController.animateTo(weekday);
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<CalendarEvent> getEventsForWeekday(int weekday) {
    DateTime today = DateTime.now();
    DateTime targetDay = today
        .subtract(Duration(days: today.weekday))
        .add(Duration(days: weekday + (nextWeek ? 7 : 0) + 1));
    int date = dateToInt(targetDay.day.toString() +
        '.' +
        targetDay.month.toString() +
        '.' +
        targetDay.year.toString());
    return Calendar.events.where((event) {
      return dateToInt(event.start.date) <= date &&
          date <= dateToInt(event.end.date);
    }).toList();
  }

  int dateToInt(String date) {
    return int.parse(date.split('.')[0]) +
        int.parse(date.split('.')[1]) * 31 +
        int.parse(date.split('.')[2]) * 365;
  }
}
