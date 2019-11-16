import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'CourseEditWidget.dart';

class CourseEditView extends CourseEditState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text((Data.subjects[widget.subject.subjectID.toUpperCase()] ?? widget.subject.subjectID) + ' ' + widget.subject.teacherID.toUpperCase()),
      children: <Widget>[
        // Writing option
        CheckboxListTile(
          value: exams,
          onChanged: (bool value) {
            setState(() {
              // Save change
              widget.subject.writeExams = value;
              syncTags(syncSelections: false);
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
          margin: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                widget.subject.writeExams = exams;
                syncTags(syncSelections: false);
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
