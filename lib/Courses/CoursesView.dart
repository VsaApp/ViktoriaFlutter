import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'CourseEdit/CourseEditWidget.dart';
import 'CoursesPage.dart';

class CoursesPageView extends CoursesPageState {
  @override
  Widget build(BuildContext context) {
    List<TimetableSubject> selectedSubjects = [];

    // Get all selected subjects...
    Data.timetable.days.forEach((day) => day.units.forEach((unit) {
          if (unit.subjects.length > 0) {
            int selectedA = getSelectedIndex(unit.subjects, week: 0) ??
                unit.subjects.length;
            int selectedB = getSelectedIndex(unit.subjects, week: 1) ??
                unit.subjects.length;
            if (selectedA < unit.subjects.length)
              selectedSubjects.add(unit.subjects[selectedA]);
            if (selectedB != selectedA && selectedB < unit.subjects.length)
              selectedSubjects.add(unit.subjects[selectedB]);
          }
        }));

    Map<String, List<TimetableSubject>> courses = {};

    // Add to subjects to map
    selectedSubjects.forEach((subject) {
      if (subject.subjectID != AppLocalizations.of(context).lunchBreak &&
          subject.subjectID != AppLocalizations.of(context).freeLesson) {
        String key = subject.subjectID + subject.teacherID;
        if (courses.containsKey(key)) {
          courses[key].add(subject);
        } else
          courses[key] = [subject];
      }
    });

    List<Widget> sections = [];
    List<Widget> section0Items = [];
    List<Widget> section1Items = [];
    List<Widget> section2Items = [];
    List<Widget> section3Items = [];

    courses.keys.toList().forEach((key) {
      String lesson = Data.subjects[courses[key][0].subjectID.toUpperCase()] ??
          courses[key][0].subjectID;
      if (lesson == Data.subjects['D'] ||
          lesson == Data.subjects['E'] ||
          lesson == Data.subjects['F'] ||
          lesson == Data.subjects['L'] ||
          lesson == Data.subjects['S'] ||
          lesson == Data.subjects['KU'] ||
          lesson == Data.subjects['MU'] ||
          lesson == Data.subjects['MC'] ||
          lesson == Data.subjects['UC'] ||
          lesson == Data.subjects['SG']) {
        section0Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Data.subjects['EK'] ||
          lesson == Data.subjects['GE'] ||
          lesson == Data.subjects['PL'] ||
          lesson == Data.subjects['SW'] ||
          lesson == Data.subjects['DP'] ||
          lesson == Data.subjects['PK']) {
        section1Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Data.subjects['BI'] ||
          lesson == Data.subjects['CH'] ||
          lesson == Data.subjects['NW'] ||
          lesson == Data.subjects['IF'] ||
          lesson == Data.subjects['MI'] ||
          lesson == Data.subjects['M'] ||
          lesson == Data.subjects['PH']) {
        section2Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else {
        section3Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      }
    });
    sections.add(Section(
      title: AppLocalizations.of(context).coursesLanguagesArts,
      children: section0Items,
    ));
    sections.add(Section(
      title: AppLocalizations.of(context).coursesSocialSciences,
      children: section1Items,
    ));
    sections.add(Section(
      title: AppLocalizations.of(context).coursesNatureSciences,
      children: section2Items,
    ));
    sections.add(Section(
      title: AppLocalizations.of(context).coursesOthers,
      children: section3Items,
    ));

    return ListView(
      shrinkWrap: true,
      children: (courses.keys.toList().length > 0)
          ? sections
          :
          // No subjects are selected in the timetable
          <Widget>[Center(child: Text(AppLocalizations.of(context).noCourses))],
    );
  }
}

class CourseRow extends StatefulWidget {
  final List<TimetableSubject> subjects;

  CourseRow({
    Key key,
    this.subjects,
  }) : super(key: key);

  @override
  CourseRowView createState() => CourseRowView();
}

class CourseRowView extends State<CourseRow> {
  String name;
  String teacher;
  String course;
  List<String> blocks;
  bool _exams;

  @override
  void initState() {
    name = Data.subjects[widget.subjects[0].subjectID.toUpperCase()] ??
        widget.subjects[0].subjectID;
    teacher = widget.subjects[0].teacherID.toUpperCase();
    course = '';
    blocks = [];
    _exams = widget.subjects[0].writeExams;

    // Create list of blocks
    widget.subjects.forEach((subject) {
      if (course.length == 0) course = subject.courseID.split('-')[1];
      if (!blocks.contains(subject.courseID)) blocks.add(subject.courseID);
    });

    if (course.length == 0 || course.contains('+'))
      course = '-';
    else {
      course = course.replaceFirst('l', 'LK ').replaceFirst('g', 'GK ');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (name == null) return Container();

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
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Course teacher
                        Container(
                            width: constraints.maxWidth * 0.70,
                            child: Text(
                              teacher,
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
                            course,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Writing selected
                        Container(
                          width: constraints.maxWidth * 0.20,
                          child: Text(
                            (_exams)
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
                                    blocks: blocks,
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
