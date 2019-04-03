import 'package:flutter/material.dart';

import '../../Localizations.dart';
import '../../SectionWidget.dart';
import 'UnitPlanSelectDialogOption/UnitPlanSelectDialogOptionWidget.dart';
import 'UnitPlanSelectDialogWidget.dart';

class UnitPlanSelectDialogView extends UnitPlanSelectDialogState {
  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      child: Column(
        children: [
          getABSubjects().map((subject) =>
              UnitPlanSelectDialogOption(
                  day: day,
                  lesson: lesson,
                  subject: subject,
                  onSelected: optionSelected)),
          [
            (getASubjects().length > 0)
                ? Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Section(
              title: AppLocalizations
                  .of(context)
                  .aWeek,
              children: getASubjects()
                  .map((subject) =>
                  UnitPlanSelectDialogOption(
                      day: day,
                      lesson: lesson,
                      subject: subject,
                      onSelected: optionSelected))
                  .cast<Widget>()
                  .toList(),
              paddingTop: 0,
              paddingBottom: 0,
              margin: 0,
            ))
                : Container(),
            getBSubjects().length > 0
                ? Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Section(
              title: AppLocalizations
                  .of(context)
                  .bWeek,
              children: getBSubjects()
                  .map((subject) =>
                  UnitPlanSelectDialogOption(
                      day: day,
                      lesson: lesson,
                      subject: subject,
                      onSelected: optionSelected))
                  .cast<Widget>()
                  .toList(),
              paddingTop: 0,
              paddingBottom: 0,
              margin: 0,
            ))
                : Container()
          ]
        ].expand((i) => i).cast<Widget>().toList(),
      ),
    );
    if (widget.enableWrapper) {
      return SimpleDialog(
        title: Text((day.lessons.indexOf(lesson) + 1).toString() +
            AppLocalizations
                .of(context)
                .nUnit),
        children: <Widget>[item],
      );
    }
    return item;
  }
}
