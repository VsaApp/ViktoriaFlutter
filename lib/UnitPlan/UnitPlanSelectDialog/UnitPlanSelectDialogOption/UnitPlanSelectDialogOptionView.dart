import 'package:flutter/material.dart';

import '../../../Courses/CourseEdit/CourseEditWidget.dart';
import '../../../Keys.dart';
import '../../../Localizations.dart';
import '../../UnitPlanModel.dart';
import '../../UnitPlanRow/UnitPlanRowWidget.dart';
import 'UnitPlanSelectDialogOptionWidget.dart';

class UnitPlanSelectDialogOptionView extends UnitPlanSelectDialogOptionState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        widget.onSelected(subject);
          bool _selected = (sharedPreferences.getKeys().where((key) => key == Keys.exams(
          sharedPreferences.getString(Keys.grade),
          lesson.subjects[lesson.subjects.indexOf(subject)].lesson.toUpperCase())).length > 0
        );
        if (!_selected && lesson.subjects[lesson.subjects.indexOf(subject)].block != null &&
            lesson.subjects[lesson.subjects.indexOf(subject)].lesson != AppLocalizations.of(context).freeLesson) {
          // Show writing option dialog
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context2) {
              return CourseEdit(
                subject: lesson.subjects[lesson.subjects.indexOf(subject)],
                blocks: [lesson.subjects[lesson.subjects.indexOf(subject)].block],
                onExamChange: (_) {
                  if (mounted) setState(() {
                    /*UnitPlan.setAllSelections(
                                  sharedPreferences);*/
                  });
                },
              );
            },
          );
        }
      },
      child: UnitPlanRow(
        weekday: UnitPlan.days.indexOf(day),
        subject: subject,
        unit: day.lessons.indexOf(lesson),
        showUnit: false,
        sharedPreferences: sharedPreferences,
      ),
    );
  }
}
