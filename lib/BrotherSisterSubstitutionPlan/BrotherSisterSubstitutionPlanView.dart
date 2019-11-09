import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import '../SubstitutionPlan/SubstitutionPlanData.dart' as substitutionPlan;
import '../SubstitutionPlan/SubstitutionPlanDayList/SubstitutionPlanDayListWidget.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../Timetable/TimetableData.dart' as timetable;
import 'BrotherSisterSubstitutionPlanPage.dart';

class BrotherSisterSubstitutionPlanPageView
    extends BrotherSisterSubstitutionPlanPageState {
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
      body: LayoutBuilder(builder: (context, constraints) {
        return Hero(
          tag: 'substitutionPlan-' + widget.grade,
          child: TabProxy(
            weekdays: days.map((day) => day.weekday).toList(),
            tabs: days
                .map((day) =>
                SubstitutionPlanDayList(
                  day: day,
                  dayIndex: days.indexOf(day),
                  temp: true,
                  grade: widget.grade,
                  sort: false,
                ))
                .toList(),
            controller: controller,
            onUpdate: () async {
              final days1 = await timetable.download(
                widget.grade ?? Storage.getString(Keys.grade), 
                true, 
                onFinished: (successfully) => dataUpdated(context, successfully, AppLocalizations.of(context).rsubstitutionPlan)
              );
              setState(() {
                days = substitutionPlan.load(days1, true);
              });
            },
          ),
        );
      })
    );
  }
}
