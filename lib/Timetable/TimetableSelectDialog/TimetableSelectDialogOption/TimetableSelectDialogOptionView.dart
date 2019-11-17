import 'package:flutter/material.dart';

import '../../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../../TimetableRow/TimetableRowWidget.dart';
import 'TimetableSelectDialogOptionWidget.dart';

class TimetableSelectDialogOptionView extends TimetableSelectDialogOptionState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () {
        widget.onSelected(subject);

        if (!subject.examIsSet &&
            subject.block != null &&
            subject.subjectID != AppLocalizations.of(context).freeLesson) {
          if (subject.courseID.split('-')[1].startsWith('l')) {
            subject.writeExams = true;
            return;
          }
          // Show writing option dialog
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context2) {
              return CourseEdit(
                subject: subject,
                blocks: [subject.block],
                onExamChange: (_) {
                  if (mounted)
                    setState(() {
                      //Data.timetable.setAllSelections();
                    });
                },
              );
            },
          );
        }
      },
      child: TimetableRow(
        weekday: day.day,
        subject: subject,
        unit: unit.unit,
        showUnit: false,
        isDialog: true,
      ),
    );
  }
}
