import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../Timetable/TimetableData.dart' as Timetable;
import '../../Timetable/TimetableModel.dart';
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
    setState(() {
      exams = Storage.getBool(Keys.exams(Storage.getString(Keys.grade),
          widget.subject.lesson.toUpperCase())) ??
          true;
    });
    List<TimetableDay> days = Timetable.getTimetable();
    days.forEach((day) {
      day.lessons.forEach((lesson) {
        TimetableSubject _selected = getSelectedSubject(
            lesson.subjects, days.indexOf(day), day.lessons.indexOf(lesson));
        if (_selected == null) return;
        if (_selected.lesson == widget.subject.lesson) {
          subjects1.add({
            'weekday': days.indexOf(day),
            'unit': day.lessons.indexOf(lesson),
            'subject': _selected
          });
        }
      });
    });
    super.initState();
  }
}
