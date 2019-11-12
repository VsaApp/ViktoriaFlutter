import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'CourseEditWidget.dart';
import 'RoomEdit/RoomEditView.dart';

class CourseEditView extends CourseEditState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.subject.subjectID + ' ' + widget.subject.teacherID),
      children: <Widget>[
        // Writing option
        CheckboxListTile(
          value: exams,
          onChanged: (bool value) {
            setState(() {
              // Save change
              Storage.setBool(Keys.exams(widget.subject.courseID), value);
              syncTags();
              exams = value;
              if (widget.onExamChange != null) {
                widget.onExamChange(exams);
              }
              Data.substitutionPlan.updateFilter();
            });
          },
          title: Text(AppLocalizations.of(context).writeExams),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
          child: Column(
            children:
                subjects1.map((subject) => RoomEdit(subject: subject)).toList(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                Storage.setBool(
                    Keys.exams(widget.subject.courseID),
                    exams);
                syncTags();
                if (widget.onExamChange != null) {
                  widget.onExamChange(exams);
                }

                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).ok),
            ),
          ),
        ),
      ],
    );
  }
}
