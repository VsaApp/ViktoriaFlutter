import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Home/HomePage.dart';
import '../../Calendar/CalendarModel.dart';
import '../../Keys.dart';
import '../../Localizations.dart';
import '../../ReplacementPlan/ReplacementPlanModel.dart';
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
  String originalWeek;
  bool showWorkGroups = false;
  bool showCalendar = false;
  bool showCafetoria = false;
  bool thisWeek = true;

  Future update() async {
    await unitplan.download(sharedPreferences.getString(Keys.grade), false);
    await replacementplan.load(unitplan.getUnitPlan(), false);
    setWeeks();
    setState(() => widget.days = unitplan.getUnitPlan());
  }

  void setWeeks() {
    // Get the week number of the shown week...
    DateTime today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    DateTime startOfYear = DateTime(today.year, 1, 1, 0, 0);
    int firstMonday = startOfYear.weekday;
    int daysInFirstWeek = 8 - firstMonday;
    Duration diff = today.difference(startOfYear);
    int weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
    if (daysInFirstWeek > 3) weeks++;
    if (!thisWeek) weeks++;
    String currentWeek = weeks % 2 == 0 ? 'A' : 'B';

    // Set all days to this week...
    UnitPlan.days.forEach((UnitPlanDay day) => day.showWeek = currentWeek);

    // If there are changes for other weeks, set that days to this week...
    DateTime dateOfMonday = today.add(Duration(
        days: thisWeek ? -today.weekday : DateTime.sunday + 1 - today.weekday));
    for (int i = 0; i < ReplacementPlan.days.length; i++) {
      ReplacementPlanDay day = ReplacementPlan.days[i];
      if (day.weektype != currentWeek) {
        DateTime date = DateTime(
            int.parse(day.date.split('.')[2]),
            int.parse(day.date.split('.')[1]),
            int.parse(day.date.split('.')[0]));
        for (int j = 0; j < UnitPlan.days.length; j++) {
          DateTime dateOfDay = dateOfMonday.add(Duration(days: j));
          if (date.isAfter(today) && dateOfDay.weekday <= date.weekday)
            UnitPlan.days[j].showWeek = day.weektype;
          else if (date.isBefore(today) && dateOfDay.weekday >= date.weekday)
            UnitPlan.days[j].showWeek = day.weektype;
        }
      }
    }
  }

  int getCurrentWeekday() {
    int weekday = DateTime.now().weekday - 1;
    bool over = false;
    if (weekday > 4) {
      weekday = 0;
      thisWeek = false;
    } else if (widget.days[weekday].lessons.length > 0) {
      if (DateTime.now().isAfter(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
      ).add(Duration(
          minutes: [
        60,
        130,
        210,
        280,
        360,
        420,
        480,
        545
      ][widget.days[weekday].getUserLesseonsCount(
                  sharedPreferences, AppLocalizations.of(context).freeLesson) -
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

      int weekday = getCurrentWeekday();
      tabController.animateTo(weekday);
      setWeeks();

      HomePageState.updateWeek(UnitPlan.days[weekday].showWeek);
      tabController.addListener(() {
        if (originalWeek != null) {
          UnitPlan.days[tabController.previousIndex].showWeek = originalWeek;
          originalWeek = null;
        }
        HomePageState.updateWeek(UnitPlan.days[tabController.index].showWeek);
      });

      // Add week listener...
      HomePageState.weekChanged = (String week) {
        if (originalWeek == null)
          originalWeek = UnitPlan.days[tabController.index].showWeek;
        if (mounted)
          setState(() => UnitPlan.days[tabController.index].showWeek = week);
      };
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
        .add(Duration(days: weekday + (!thisWeek ? 7 : 0) + 1));
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
