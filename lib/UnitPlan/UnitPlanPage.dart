import 'package:flutter/material.dart';

import '../Home/HomePage.dart';
import 'UnitPlanData.dart';
import 'UnitPlanDayList/UnitPlanDayListWidget.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  Function() listener;

  @override
  void initState() {
    listener = () => setState(() => null);
    HomePageState.replacementplanUpdatedListeners.add(listener);
    HomePageState.setWeekChangeable(true);
    super.initState();
  }

  @override
  void dispose() {
    HomePageState.replacementplanUpdatedListeners.remove(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[UnitPlanDayList(days: getUnitPlan())]);
  }
}
