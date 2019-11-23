import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'TimetableSelectDialogOptionView.dart';

class TimetableSelectDialogOption extends StatefulWidget {
  final TimetableDay day;
  final TimetableUnit unit;
  final TimetableSubject subject;
  final Function(TimetableSubject subject) onSelected;

  TimetableSelectDialogOption({
    Key key,
    this.day,
    this.unit,
    this.subject,
    this.onSelected,
  }) : super(key: key);

  @override
  TimetableSelectDialogOptionView createState() =>
      TimetableSelectDialogOptionView();
}

abstract class TimetableSelectDialogOptionState
    extends State<TimetableSelectDialogOption>
    with SingleTickerProviderStateMixin {
  TimetableDay day;
  TimetableUnit unit;
  TimetableSubject subject;

  @override
  void initState() {
    day = widget.day;
    unit = widget.unit;
    subject = widget.subject;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
