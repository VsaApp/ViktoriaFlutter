import 'package:flutter/material.dart';

import '../../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../TimetableModel.dart';
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
                Storage.getString(Keys.grade),
                lesson.subjects[lesson.subjects.indexOf(subject)].lesson
                    .toUpperCase()))
            .length >
            0);
        if (!_selected &&
            lesson.subjects[lesson.subjects.indexOf(subject)].block != null &&
            lesson.subjects[lesson.subjects.indexOf(subject)].lesson !=
                AppLocalizations
                    .of(context)
                    .freeLesson) {
          // Show writing option dialog
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context2) {
              return CourseEdit(
                subject: lesson.subjects[lesson.subjects.indexOf(subject)],
                blocks: [
                  lesson.subjects[lesson.subjects.indexOf(subject)].block
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
        weekday: Timetable.days.indexOf(day),
        subject: subject,
        unit: day.lessons.indexOf(lesson),
        showUnit: false,
        isDialog: true,
      ),
    );
  }
}
