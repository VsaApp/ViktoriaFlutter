import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../UnitPlanModel.dart';
import 'UnitPlanSelectDialogOptionView.dart';

class UnitPlanSelectDialogOption extends StatefulWidget {
  UnitPlanDay day;
  UnitPlanLesson lesson;
  UnitPlanSubject subject;
  SharedPreferences sharedPreferences;
  final Function(UnitPlanSubject subject) onSelected;

  UnitPlanSelectDialogOption({Key key, this.day, this.lesson, this.subject, this.onSelected, this.sharedPreferences}) : super(key: key);

  @override
  UnitPlanSelectDialogOptionView createState() => UnitPlanSelectDialogOptionView();
}

abstract class UnitPlanSelectDialogOptionState extends State<UnitPlanSelectDialogOption>
    with SingleTickerProviderStateMixin {
      
  SharedPreferences sharedPreferences;
  UnitPlanDay day;
  UnitPlanLesson lesson;
  UnitPlanSubject subject;

  @override
  void initState() {
    sharedPreferences = widget.sharedPreferences;
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
