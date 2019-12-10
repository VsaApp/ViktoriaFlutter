import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Pages/Home/ExpandWidget.dart';
import 'package:viktoriaflutter/Pages/Home/HomePage.dart';
import 'package:viktoriaflutter/Pages/MainFrame/MainFramePage.dart';
import 'package:viktoriaflutter/Pages/SubstitutionPlan/SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import 'package:viktoriaflutter/Pages/Timetable/TimetableRow/TimetableRowWidget.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Widgets/GroupHeader.dart';
import 'package:viktoriaflutter/Widgets/GroupList.dart';

// ignore: public_member_api_docs
class HomePageView extends HomePageState {
  @override
  Widget build(BuildContext context) {
    return GroupList(
      groups: [
        if (currentTtDay != null)
          Group(
            header: GroupHeader(
              title:
                  '${AppLocalizations.of(context).nextLessons} - ${AppLocalizations.of(context).weekdays[currentTtDay.day]}',
              count: currentTtDay.units.length,
              alignment: Alignment.bottomLeft,
            ),
            children: [
              ...currentTtDay.units
                  .map((unit) {
                    return GestureDetector(
                      onTap: () => MainFrameState.setPage(2),
                      child: TimetableRow(subject: unit.getSelected()),
                    );
                  })
                  .toList()
                  .sublist(0, math.min(currentTtDay.units.length, 3)),
              if (currentTtDay.units.length > 3)
                ExpandWidget(
                  text:
                      '${currentTtDay.units.length - 3} ${AppLocalizations.of(context).moreUnits}',
                  onTab: () => MainFrameState.setPage(2),
                )
            ],
          ),
        if (currentSpDay != null)
          Group(
            header: GroupHeader(
              title:
                  '${AppLocalizations.of(context).myChanges} - ${AppLocalizations.of(context).weekdays[currentSpDay.date.weekday - 1]}',
              count: currentSpDay.myChanges.length +
                  currentSpDay.undefinedChanges.length +
                  currentSpDay.unparsed[Data.timetable.grade].length,
              alignment: Alignment.bottomLeft,
            ),
            emptyInfo: AppLocalizations.of(context).noChanges,
            children: [
              ...currentSpDay.myChanges
                  .map((substitution) {
                    return GestureDetector(
                      onTap: () => MainFrameState.setPage(0),
                      child: SubstitutionPlanRow(
                        substitutions: currentSpDay.myChanges,
                        index: currentSpDay.myChanges.indexOf(substitution),
                        context: context,
                      ),
                    );
                  })
                  .toList()
                  .sublist(0, math.min(currentSpDay.myChanges.length, 3)),
              if (currentSpDay.myChanges.length +
                      currentSpDay.undefinedChanges.length +
                      currentSpDay.unparsed[Data.timetable.grade].length >
                  3)
                ExpandWidget(
                  text:
                      '${currentSpDay.myChanges.length + currentSpDay.undefinedChanges.length + currentSpDay.unparsed[Data.timetable.grade].length - 3} ${AppLocalizations.of(context).moreChanges}',
                  onTab: () => MainFrameState.setPage(0),
                )
            ],
          )
      ],
    );
  }
}
