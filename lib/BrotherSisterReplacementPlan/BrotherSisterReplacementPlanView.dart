import 'package:flutter/material.dart';

import '../Keys.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../ReplacementPlan/ReplacementPlanDayList/ReplacementPlanDayListWidget.dart';
import '../Storage.dart';
import '../TabProxy.dart';
import '../UnitPlan/UnitPlanData.dart' as unitplan;
import 'BrotherSisterReplacementPlanPage.dart';

class BrotherSisterReplacementPlanPageView
    extends BrotherSisterReplacementPlanPageState {
  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade),
        elevation: 0.0,
      ),
      body: Hero(
        tag: 'replacementplan-' + widget.grade,
        child: TabProxy(
          weekdays: days.map((day) => day.weekday).toList(),
          tabs: days
              .map((day) =>
              ReplacementPlanDayList(
                day: day,
                dayIndex: days.indexOf(day),
                temp: true,
                grade: widget.grade,
                sort: false,
              ))
              .toList(),
          controller: controller,
          onUpdate: () async {
            unitplan
                .download(widget.grade ?? Storage.getString(Keys.grade), true)
                .then((days1) {
              setState(() {
                days = replacementplan.load(days1, true);
              });
            });
          },
        ),
      ),
    );
  }
}
