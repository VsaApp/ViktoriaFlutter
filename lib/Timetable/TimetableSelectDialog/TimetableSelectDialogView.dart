import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'TimetableSelectDialogOption/TimetableSelectDialogOptionWidget.dart';
import 'TimetableSelectDialogWidget.dart';

// ignore: public_member_api_docs
class TimetableSelectDialogView extends TimetableSelectDialogState {
  @override
  Widget build(BuildContext context) {
    final Widget item = Container(
      child: Column(
        children: unit.subjects.map((subject) =>
              TimetableSelectDialogOption(
                  unit: unit,
                  subject: subject,
                  onSelected: optionSelected)).toList(),
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
