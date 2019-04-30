import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../Subjects/SubjectsModel.dart';
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../UnitPlan/UnitPlanModel.dart';
import 'CourseEdit/CourseEditWidget.dart';
import 'CoursesPage.dart';

class CoursesPageView extends CoursesPageState {
  @override
  Widget build(BuildContext context) {
    List<UnitPlanSubject> selectedSubjects = [];

    // Get all selected subjects...
    UnitPlan.getUnitPlan().forEach((day) => day.lessons.forEach((lesson) {
          if (lesson.subjects.length > 0) {
            int selectedA = getSelectedIndex(
                    lesson.subjects,
                    UnitPlan.getUnitPlan().indexOf(day),
                day.lessons.indexOf(lesson),
                week: 'A') ??
                lesson.subjects.length;
            int selectedB = getSelectedIndex(
                lesson.subjects,
                UnitPlan.getUnitPlan().indexOf(day),
                day.lessons.indexOf(lesson),
                week: 'B') ??
                lesson.subjects.length;
            if (selectedA < lesson.subjects.length)
              selectedSubjects.add(lesson.subjects[selectedA]);
            if (selectedB != selectedA && selectedB < lesson.subjects.length)
              selectedSubjects.add(lesson.subjects[selectedB]);
          }
        }));

    Map<String, List<UnitPlanSubject>> courses = {};

    // Add to subjects to map
    selectedSubjects.forEach((subject) {
      if (subject.lesson != AppLocalizations.of(context).lunchBreak &&
          subject.lesson != AppLocalizations.of(context).freeLesson) {
        String key = subject.lesson + subject.teacher;
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
      String lesson = courses[key][0].lesson;
      if (lesson == Subjects.subjects['D'] ||
          lesson == Subjects.subjects['E'] ||
          lesson == Subjects.subjects['F'] ||
          lesson == Subjects.subjects['L'] ||
          lesson == Subjects.subjects['S'] ||
          lesson == Subjects.subjects['KU'] ||
          lesson == Subjects.subjects['MU'] ||
          lesson == Subjects.subjects['MC'] ||
          lesson == Subjects.subjects['UC'] ||
          lesson == Subjects.subjects['SG']) {
        section0Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Subjects.subjects['EK'] ||
          lesson == Subjects.subjects['GE'] ||
          lesson == Subjects.subjects['PL'] ||
          lesson == Subjects.subjects['SW'] ||
          lesson == Subjects.subjects['DP'] ||
          lesson == Subjects.subjects['PK']) {
        section1Items.add(CourseRow(
          subjects: courses[key].toList(),
        ));
      } else if (lesson == Subjects.subjects['BI'] ||
          lesson == Subjects.subjects['CH'] ||
          lesson == Subjects.subjects['NW'] ||
          lesson == Subjects.subjects['IF'] ||
          lesson == Subjects.subjects['MI'] ||
          lesson == Subjects.subjects['M'] ||
          lesson == Subjects.subjects['PH']) {
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
      title: AppLocalizations.of(context).coursesSocialScienes,
      children: section1Items,
    ));
    sections.add(Section(
      title: AppLocalizations.of(context).coursesNatureScienes,
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
          // No subjects are selected in the unit plan
          <Widget>[
              Center(child: Text(AppLocalizations.of(context).noCourses))
            ],
    );
  }
}

class CourseRow extends StatefulWidget {
  final List<UnitPlanSubject> subjects;

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
    name = widget.subjects[0].lesson;
    teacher = widget.subjects[0].teacher;
    course = '';
    blocks = [];
    _exams = Storage.getBool(Keys.exams(Storage.getString(Keys.grade),
            widget.subjects[0].lesson.toUpperCase())) ??
        true;

    // Create list of blocks
    widget.subjects.forEach((subject) {
      if (course.length == 0) course = subject.course;
      if (!blocks.contains(subject.block)) blocks.add(subject.block);
    });

    if (course.length == 0) course = '-';
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
