import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'TimetableSelectDialogOption/TimetableSelectDialogOptionWidget.dart';
import 'TimetableSelectDialogWidget.dart';

class TimetableSelectDialogView extends TimetableSelectDialogState {
  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      child: Column(
        children: [
          getABSubjects().map((subject) =>
              TimetableSelectDialogOption(
                  day: day,
                  unit: unit,
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
                  TimetableSelectDialogOption(
                      day: day,
                      unit: unit,
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
                  TimetableSelectDialogOption(
                      day: day,
                      unit: unit,
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
        title: Text((day.units.indexOf(unit) + 1).toString() +
            AppLocalizations
                .of(context)
                .nUnit),
        children: <Widget>[item],
      );
    }
    return item;
  }
}
