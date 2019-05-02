import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import '../../Calendar/CalendarModel.dart';
import '../UnitPlanModel.dart';
import 'UnitPlanDayListView.dart';

class UnitPlanDayList extends StatefulWidget {
  UnitPlanDay day;
  int dayIndex;

  UnitPlanDayList({
    Key key,
    @required this.day,
    @required this.dayIndex,
  }) : super(key: key);

  @override
  UnitPlanDayListView createState() => UnitPlanDayListView();
}

abstract class UnitPlanDayListState extends State<UnitPlanDayList>
    with SingleTickerProviderStateMixin {
  String grade = '';
  TabController tabController;
  bool showWorkGroups = false;
  bool showCalendar = false;
  bool showCafetoria = false;
  bool thisWeek = true;

  @override
  void initState() {
    setState(() {
      grade = Storage.getString(Keys.grade);
      showWorkGroups = Storage.get(Keys.showWorkGroupsInUnitPlan);
      showCalendar = Storage.get(Keys.showCalendarInUnitPlan);
      showCafetoria = Storage.get(Keys.showCafetoriaInUnitPlan);
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
        .subtract(Duration(days: today.weekday < 6 ? today.weekday : 0))
        .add(Duration(days: weekday + (!thisWeek ? 7 : 0) + 1));
    return Calendar.events.where((event) {
      return (event.start.isBefore(targetDay) || event.start == targetDay) &&
          (event.end.isAfter(targetDay) || event.end == targetDay);
    }).toList();
  }
}
