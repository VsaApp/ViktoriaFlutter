import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Selection.dart';
import '../../Timetable/TimetableData.dart' as Timetable;
import 'package:viktoriaflutter/Utils/Models.dart';
import 'CourseEditView.dart';

class CourseEdit extends StatefulWidget {
  final TimetableSubject subject;
  final List<String> blocks;
  final Function onExamChange;

  CourseEdit(
      {Key key,
      @required this.subject,
      @required this.blocks,
      this.onExamChange})
      : super(key: key);

  @override
  CourseEditView createState() => CourseEditView();
}

abstract class CourseEditState extends State<CourseEdit> {
  bool exams = false;
  List<dynamic> subjects1 = [];

  @override
  void initState() {
    exams = widget.subject.writeExams;
    List<TimetableDay> days = Timetable.getTimetable();
    days.forEach((day) {
      day.units.forEach((unit) {
        TimetableSubject _selected = getSelectedSubject(unit.subjects);
        if (_selected == null) return;
        if (_selected.subjectID == widget.subject.subjectID) {
          subjects1.add({
            'weekday': days.indexOf(day),
            'unit': day.units.indexOf(unit),
            'subject': _selected
          });
        }
      });
    });
    super.initState();
  }
}
