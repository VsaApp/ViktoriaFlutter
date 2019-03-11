import 'package:flutter/material.dart';

import '../../Keys.dart';
import '../../Localizations.dart';
import '../../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../../Tags.dart';
import '../../UnitPlan/UnitPlanData.dart' as unitplan;
import 'CourseEditWidget.dart';
import 'RoomEdit/RoomEditView.dart';

class CourseEditView extends CourseEditState {
  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return SimpleDialog(
      title: Text(widget.subject.lesson + ' ' + widget.subject.teacher),
      children: <Widget>[
        // Writing option
        CheckboxListTile(
          value: exams,
          onChanged: (bool value) {
            setState(() {
              // Save change
              sharedPreferences.setBool(
                  Keys.exams(sharedPreferences.getString(Keys.grade),
                      widget.subject.lesson.toUpperCase()),
                  value);
              sharedPreferences.commit();
              syncTags();
              exams = value;
              if (widget.onExamChange != null) {
                widget.onExamChange(exams);
              }
              replacementplan.load(unitplan.getUnitPlan(), false);
            });
          },
          title: Text(AppLocalizations.of(context).writeExams),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
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
                sharedPreferences.setBool(
                    Keys.exams(sharedPreferences.getString(Keys.grade),
                        widget.subject.lesson.toUpperCase()),
                    exams);
                sharedPreferences.commit();
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
