import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Timetable/TimetableRow/TimetableRowWidget.dart';
import 'TimetableSelectDialogOptionWidget.dart';

// ignore: public_member_api_docs
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
                onExamChange: (_) {
                  if (mounted) {
                    setState(() {
                      //Data.timetable.setAllSelections();
                    });
                  }
                },
              );
            },
          );
        }
      },
      child: TimetableRow(
        subject: subject,
        showUnit: false,
        isDialog: true,
      ),
    );
  }
}
