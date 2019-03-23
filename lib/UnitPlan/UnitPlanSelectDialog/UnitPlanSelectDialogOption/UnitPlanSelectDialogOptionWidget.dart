import 'package:flutter/material.dart';

import '../../UnitPlanModel.dart';
import 'UnitPlanSelectDialogOptionView.dart';

class UnitPlanSelectDialogOption extends StatefulWidget {
  UnitPlanDay day;
  UnitPlanLesson lesson;
  UnitPlanSubject subject;
  final Function(UnitPlanSubject subject) onSelected;

  UnitPlanSelectDialogOption({
    Key key,
    this.day,
    this.lesson,
    this.subject,
    this.onSelected,
  }) : super(key: key);

  @override
  UnitPlanSelectDialogOptionView createState() =>
      UnitPlanSelectDialogOptionView();
}

abstract class UnitPlanSelectDialogOptionState
    extends State<UnitPlanSelectDialogOption>
    with SingleTickerProviderStateMixin {
  UnitPlanDay day;
  UnitPlanLesson lesson;
  UnitPlanSubject subject;

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
