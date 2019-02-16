import 'package:flutter/material.dart';

import '../../Keys.dart';
import '../../Localizations.dart';
import '../../Rooms.dart';
import '../../Tags.dart';
import 'CourseEditWidget.dart';

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
            });
          },
          title: Text(AppLocalizations.of(context).writeExams),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Column(
            children: subjects1.map((subject) {
              TextEditingController _controller = TextEditingController(
                  text: getRoom(
                      sharedPreferences,
                      subject['weekday'],
                      subject['unit'],
                      subject['subject'].lesson,
                      subject['subject'].room));
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text([
                          'Montag',
                          'Dienstag',
                          'Mittwoch',
                          'Donnerstag',
                          'Freitag'
                        ][subject['weekday']] +
                        ' ' +
                        (subject['unit'] + 1).toString() +
                        '. Stunde:'),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: subject['subject'].room,
                        contentPadding: EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                        ),
                      ),
                      onChanged: (value) {
                        setRoom(sharedPreferences, subject['weekday'],
                            subject['unit'], subject['subject'].lesson, value);
                      },
                    )
                  ],
                ),
              );
            }).toList(),
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
