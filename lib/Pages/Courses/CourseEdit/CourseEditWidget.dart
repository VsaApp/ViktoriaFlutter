import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Models/Models.dart';

import 'CourseEditView.dart';

/// Dialog to edit course properties
class CourseEdit extends StatefulWidget {
  /// One subject of the course to edit
  final TimetableSubject subject;

  /// Exam changed listener
  final Function onExamChange;

  // ignore: public_member_api_docs
  const CourseEdit({
    @required this.subject,
    this.onExamChange,
    Key key,
  }) : super(key: key);

  @override
  CourseEditView createState() => CourseEditView();
}

// ignore: public_member_api_docs
abstract class CourseEditState extends State<CourseEdit> {
  /// Writing exams option
  bool exams = false;

  @override
  void initState() {
    exams = widget.subject.writeExams;
    super.initState();
  }
}
