import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../ReplacementPlan/ReplacementPlanDayList/ReplacementPlanDayListWidget.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Update.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
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
      body: LayoutBuilder(builder: (context, constraints) {
        return Hero(
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
              final days1 = await unitplan.download(
                widget.grade ?? Storage.getString(Keys.grade), 
                true, 
                onFinished: (successfully) => dataUpdated(context, successfully, AppLocalizations.of(context).replacementPlan)
              );
              setState(() {
                days = replacementplan.load(days1, true);
              });
            },
          ),
        );
      })
    );
  }
}
