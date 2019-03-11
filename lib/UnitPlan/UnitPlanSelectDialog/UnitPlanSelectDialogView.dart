import 'package:flutter/material.dart';

import '../../SectionWidget.dart';
import '../../Localizations.dart';
import 'UnitPlanSelectDialogOption/UnitPlanSelectDialogOptionWidget.dart';
import 'UnitPlanSelectDialogWidget.dart';

class UnitPlanSelectDialogView extends UnitPlanSelectDialogState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text((day.lessons.indexOf(lesson) + 1).toString() + AppLocalizations.of(context).nUnit),
      children: [
        getABSubjects().map((subject) => 
          UnitPlanSelectDialogOption(day: day, lesson: lesson, subject: subject, sharedPreferences: sharedPreferences, onSelected: optionSelected)),
        [
          (getASubjects().length > 0) ?
          Section(
            title: AppLocalizations.of(context).aWeek,
            children: getASubjects().map((subject) =>
              UnitPlanSelectDialogOption(day: day, lesson: lesson, subject: subject, sharedPreferences: sharedPreferences, onSelected: optionSelected)
            ).cast<Widget>().toList(),
            paddingTop: 0,
            paddingBottom: 0,
            margin: 0,
          ) : Container(),
          getBSubjects().length > 0 ?
          Section(
            title: AppLocalizations.of(context).bWeek,
            children: getBSubjects().map((subject) =>
              UnitPlanSelectDialogOption(day: day, lesson: lesson, subject: subject, sharedPreferences: sharedPreferences, onSelected: optionSelected)
            ).cast<Widget>().toList(),
            paddingTop: 0,
            paddingBottom: 0,
            margin: 0,
          )
          : Container()
        ]
      ].expand((i) => i).cast<Widget>().toList(),
    );
  }
}
