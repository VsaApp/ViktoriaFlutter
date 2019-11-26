import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/SubjectRow.dart';

import 'package:viktoriaflutter/Utils/Times.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// One unit in the timetable
class TimetableRow extends SubjectRow {
  // ignore: public_member_api_docs
  TimetableRow({
    @required TimetableSubject subject,
    bool showUnit = true,
    Key key,
    bool isDialog = false,
  }) : super(
          details: [
            SubjectRowDetails(
              title: Data.subjects[subject.subjectID.toUpperCase()] ??
                  subject.subjectID,
              subtitle: subject.unit != 5 ? times[subject.unit] : '',
              unit: subject.unit,
              infoRightTop: subject.teacherID.toUpperCase(),
              infoRightBottom: subject.roomID,
            )
          ],
          index: 0,
          showUnit: subject.unit != 5 && showUnit,
          coloredInfos: false,
          hideUnit: isDialog,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    if (details[0].unit == 5) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            details[0].title,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      );
    }
    return super.build(context);
  }
}
