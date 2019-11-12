import 'package:flutter/material.dart';

import '../../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import '../../TimetableRow/TimetableRowWidget.dart';
import 'TimetableSelectDialogOptionWidget.dart';

class TimetableSelectDialogOptionView extends TimetableSelectDialogOptionState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        widget.onSelected(subject);
        bool _selected = (Storage.getKeys()
            .where((key) =>
        key ==
            Keys.exams(
                unit.subjects[unit.subjects.indexOf(subject)].courseID))
            .length >
            0);
        if (!_selected &&
            unit.subjects[unit.subjects.indexOf(subject)].block != null &&
            unit.subjects[unit.subjects.indexOf(subject)].subjectID !=
                AppLocalizations
                    .of(context)
                    .freeLesson) {
          // Show writing option dialog
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context2) {
              return CourseEdit(
                subject: unit.subjects[unit.subjects.indexOf(subject)],
                blocks: [
                  unit.subjects[unit.subjects.indexOf(subject)].block
                ],
                onExamChange: (_) {
                  if (mounted)
                    setState(() {
                      //Timetable.setAllSelections();
                    });
                },
              );
            },
          );
        }
      },
      child: TimetableRow(
        weekday: Data.timetable.days.indexOf(day),
        subject: subject,
        unit: day.units.indexOf(unit),
        showUnit: false,
        isDialog: true,
      ),
    );
  }
}
