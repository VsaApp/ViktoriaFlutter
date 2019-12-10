import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Widgets/SectionWidget.dart';

import 'TimetableSelectDialogOption/TimetableSelectDialogOptionWidget.dart';
import 'TimetableSelectDialogWidget.dart';

// ignore: public_member_api_docs
class TimetableSelectDialogView extends TimetableSelectDialogState {
  @override
  Widget build(BuildContext context) {
    final Widget item = Container(
      child: Column(
        children: [
          getABSubjects().map((subject) => TimetableSelectDialogOption(
              unit: unit, subject: subject, onSelected: optionSelected)),
          [
            if (getASubjects().isNotEmpty)
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Section(
                    title: AppLocalizations.of(context).aWeek,
                    paddingTop: 0,
                    paddingBottom: 0,
                    margin: 0,
                    children: getASubjects()
                        .map((subject) => TimetableSelectDialogOption(
                            unit: unit,
                            subject: subject,
                            onSelected: optionSelected))
                        .cast<Widget>()
                        .toList(),
                  )),
            if (getBSubjects().isNotEmpty)
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Section(
                    title: AppLocalizations.of(context).bWeek,
                    paddingTop: 0,
                    paddingBottom: 0,
                    margin: 0,
                    children: getBSubjects()
                        .map((subject) => TimetableSelectDialogOption(
                            unit: unit,
                            subject: subject,
                            onSelected: optionSelected))
                        .cast<Widget>()
                        .toList(),
                  ))
          ]
        ].expand((i) => i).cast<Widget>().toList(),
      ),
    );
    if (widget.enableWrapper) {
      return SimpleDialog(
        title: Text((day.units.indexOf(unit) + 1).toString() +
            AppLocalizations.of(context).nUnit),
        children: <Widget>[item],
      );
    }
    return item;
  }
}
