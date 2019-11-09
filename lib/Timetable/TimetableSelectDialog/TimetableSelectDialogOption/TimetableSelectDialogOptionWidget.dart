import 'package:flutter/material.dart';

import '../../TimetableModel.dart';
import 'TimetableSelectDialogOptionView.dart';

class TimetableSelectDialogOption extends StatefulWidget {
  TimetableDay day;
  TimetableLesson lesson;
  TimetableSubject subject;
  final Function(TimetableSubject subject) onSelected;

  TimetableSelectDialogOption({
    Key key,
    this.day,
    this.lesson,
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
  TimetableLesson lesson;
  TimetableSubject subject;

  @override
  void initState() {
    day = widget.day;
    lesson = widget.lesson;
    subject = widget.subject;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
