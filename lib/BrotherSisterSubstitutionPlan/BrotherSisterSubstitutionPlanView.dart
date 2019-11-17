import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import '../SubstitutionPlan/SubstitutionPlanDayList/SubstitutionPlanDayListWidget.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'BrotherSisterSubstitutionPlanPage.dart';

class BrotherSisterSubstitutionPlanPageView
    extends BrotherSisterSubstitutionPlanPageState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.grade),
          elevation: 0.0,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Hero(
            tag: 'substitutionPlan-' + widget.grade,
            child: TabProxy(
              weekdays: days
                  .map((day) => AppLocalizations.of(context)
                      .weekdays[day.date.weekday - 1])
                  .toList(),
              tabs: days
                  .map((day) => SubstitutionPlanDayList(
                        day: day,
                        dayIndex: days.indexOf(day),
                        temp: true,
                        grade: widget.grade,
                        sort: false,
                      ))
                  .toList(),
              controller: controller,
              onUpdate: () async {
                await SubstitutionPlanData().download(context);
                setState(() => days = Data.substitutionPlan.days);
              },
            ),
          );
        }));
  }
}
