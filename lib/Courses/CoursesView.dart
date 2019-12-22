import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'CourseEdit/CourseEditWidget.dart';
import 'CoursesPage.dart';

// ignore: public_member_api_docs
class CoursesPageView extends CoursesPageState {
  @override
  Widget build(BuildContext context) {
    final List<TimetableSubject> selectedSubjects = [];

    // Get all selected subjects...
    Data.timetable.days.forEach((day) => day.units.forEach((unit) {
          if (unit.subjects.isNotEmpty) {
            final int selectedA = getSelectedIndex(unit.subjects, week: 0) ??
                unit.subjects.length;
            final int selectedB = getSelectedIndex(unit.subjects, week: 1) ??
                unit.subjects.length;
            if (selectedA < unit.subjects.length) {
              selectedSubjects.add(unit.subjects[selectedA]);
            }
            if (selectedB != selectedA && selectedB < unit.subjects.length) {
              selectedSubjects.add(unit.subjects[selectedB]);
            }
          }
        }));

    final Map<String, List<TimetableSubject>> courses = {};

    // Add to subjects to map
    selectedSubjects.forEach((subject) {
      if (subject.subjectID != AppLocalizations.of(context).lunchBreak &&
          subject.subjectID != AppLocalizations.of(context).freeLesson) {
        final String key = subject.subjectID + subject.teacherID;
        if (courses.containsKey(key)) {
          courses[key].add(subject);
        } else {
          courses[key] = [subject];
        }
      }
    });

    final List<Widget> section0Items = [];
    final List<Widget> section1Items = [];
    final List<Widget> section2Items = [];
    final List<Widget> section3Items = [];

    courses.keys.toList().forEach((key) {
      final String lesson =
          Data.subjects[courses[key][0].subjectID] ??
              courses[key][0].subjectID;
      if (lesson == Data.subjects['d'] ||
          lesson == Data.subjects['e'] ||
          lesson == Data.subjects['f'] ||
          lesson == Data.subjects['k'] ||
          lesson == Data.subjects['s'] ||
          lesson == Data.subjects['ku'] ||
          lesson == Data.subjects['mu'] ||
          lesson == Data.subjects['mc'] ||
          lesson == Data.subjects['uc'] ||
          lesson == Data.subjects['sg']) {
        section0Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Data.subjects['ek'] ||
          lesson == Data.subjects['ge'] ||
          lesson == Data.subjects['pl'] ||
          lesson == Data.subjects['sw'] ||
          lesson == Data.subjects['dp'] ||
          lesson == Data.subjects['pk']) {
        section1Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Data.subjects['bi'] ||
          lesson == Data.subjects['ch'] ||
          lesson == Data.subjects['nw'] ||
          lesson == Data.subjects['if'] ||
          lesson == Data.subjects['mi'] ||
          lesson == Data.subjects['m'] ||
          lesson == Data.subjects['ph']) {
        section2Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else {
        section3Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      }
    });

    final List<Widget> sections = [
      Section(
        title: AppLocalizations.of(context).coursesLanguagesArts,
        children: section0Items,
      ),
      Section(
        title: AppLocalizations.of(context).coursesSocialSciences,
        children: section1Items,
      ),
      Section(
        title: AppLocalizations.of(context).coursesNatureSciences,
        children: section2Items,
      ),
      Section(
        title: AppLocalizations.of(context).coursesOthers,
        children: section3Items,
      ),
    ];

    return ListView(
      shrinkWrap: true,
      children: (courses.keys.toList().isNotEmpty)
          ? sections
          :
          // No subjects are selected in the timetable
          <Widget>[Center(child: Text(AppLocalizations.of(context).noCourses))],
    );
  }
}

/// Shows all infos of o course
class CourseRow extends StatefulWidget {
  /// All subjects of this course
  final List<TimetableSubject> subjects;

  // ignore: public_member_api_docs
  const CourseRow({
    @required this.subjects,
    Key key,
  }) : super(key: key);

  @override
  CourseRowView createState() => CourseRowView();
}

// ignore: public_member_api_docs
class CourseRowView extends State<CourseRow> {
  String _name;
  String _teacher;
  String _course;
  List<String> _blocks;
  bool _exams;

  @override
  void initState() {
    _name = Data.subjects[widget.subjects[0].subjectID] ??
        widget.subjects[0].subjectID;
    _teacher = widget.subjects[0].teacherID.toUpperCase();
    _course = '';
    _blocks = [];
    _exams = widget.subjects[0].writeExams;

    // Create list of blocks
    widget.subjects.forEach((subject) {
      if (_course.isEmpty) {
        _course = subject.courseID.split('-')[1];
      }
      if (!_blocks.contains(subject.courseID)) {
        _blocks.add(subject.courseID);
      }
    });

    if (_course.isEmpty || _course.contains('+')) {
      _course = '-';
    } else {
      _course = _course.replaceFirst('l', 'LK ').replaceFirst('g', 'GK ');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_name == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Course subject name
                        Container(
                          width: constraints.maxWidth * 0.70,
                          child: Text(
                            _name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Course teacher
                        Container(
                            width: constraints.maxWidth * 0.70,
                            child: Text(
                              _teacher,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // Course name
                        Container(
                          width: constraints.maxWidth * 0.20,
                          child: Text(
                            _course,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Writing selected
                        Container(
                          width: constraints.maxWidth * 0.20,
                          child: Text(
                            _exams
                                ? AppLocalizations.of(context).writing
                                : AppLocalizations.of(context).speaking,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // Edit button
                        Container(
                          width: constraints.maxWidth * 0.10,
                          child: IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: AppLocalizations.of(context).edit,
                              onPressed: () {
                                showDialog<String>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context1) =>
                                      CourseEdit(
                                    subject: widget.subjects[0],
                                    onExamChange: (exams) {
                                      setState(() {
                                        _exams = exams;
                                      });
                                    },
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
