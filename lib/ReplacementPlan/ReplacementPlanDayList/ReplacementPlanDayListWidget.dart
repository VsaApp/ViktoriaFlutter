import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ReplacementPlanModel.dart';
import 'ReplacementPlanDayListView.dart';
import '../../UnitPlan/UnitPlanModel.dart';
import '../../Localizations.dart';

class ReplacementPlanDayList extends StatefulWidget {
  final List<ReplacementPlanDay> days;
  final bool sort;

  ReplacementPlanDayList({Key key, this.days, this.sort}) : super(key: key);

  @override
  ReplacementPlanDayListView createState() => ReplacementPlanDayListView();
}

abstract class ReplacementPlanDayListState extends State<ReplacementPlanDayList>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  TabController tabController;
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

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;

        // Select the correct tab
        tabController = TabController(vsync: this, length: widget.days.length);
        int day = 0;
        if (widget.days.length > 1) {
          bool over = false;
          int weekday = DateTime.now().weekday;
          if (weekday <= 4) {
            if (UnitPlan.days[weekday].lessons.length > 0) {
              if (DateTime.now().isAfter(DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day, 8)
                  .add(Duration(
                      minutes: [60, 130, 210, 280, 360, 420, 480, 545][
                          UnitPlan.days[weekday].getUserLesseonsCount(instance,
                                  AppLocalizations.of(context).freeLesson) -
                              1])))) {
                over = true;
              }
            }
          }

          // If the first day is passed, select the next day...
          if (DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).add(Duration(days: (over) ? 1 : 0)).isAfter(DateTime(
                (int.parse(widget.days[0].date.split('.')[2]) < 2000)
                    ? (int.parse(widget.days[0].date.split('.')[2]) + 2000)
                    : (int.parse(widget.days[0].date.split('.')[2])),
                int.parse(widget.days[0].date.split('.')[1]),
                int.parse(widget.days[0].date.split('.')[0]),
              ))) day = 1;

          tabController.animateTo(day);
        }
      });
    });

    super.initState();
  }
}
