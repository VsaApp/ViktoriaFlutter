import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../UnitPlan/UnitPlanData.dart' as unitplan;
import '../../ReplacementPlan/ReplacementplanData.dart' as replacementplan;
import '../../Localizations.dart';
import '../../Keys.dart';
import '../UnitPlanModel.dart';
import 'UnitPlanDayListView.dart';

class UnitPlanDayList extends StatefulWidget {
  final List<UnitPlanDay> days;

  UnitPlanDayList({Key key, this.days}) : super(key: key);

  @override
  UnitPlanDayListView createState() => UnitPlanDayListView();
}

abstract class UnitPlanDayListState extends State<UnitPlanDayList> with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  String grade = '';
  TabController tabController;

  Future update() async {
    await unitplan.download(grade: sharedPreferences.getString(Keys.grade), setStatic: true);
    await replacementplan.load(unitplan.getUnitPlan(), false);
     setState(() => null);
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      sharedPreferences = instance;
      setState(() {
        grade = sharedPreferences.getString(Keys.grade);
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
            minutes: [
          60,
          130,
          210,
          280,
          360,
          420,
          480,
          545
        ][widget.days[weekday].getUserLesseonsCount(sharedPreferences, AppLocalizations.of(context).freeLesson) - 1])))) {
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
      tabController.animateTo(weekday);
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

}
