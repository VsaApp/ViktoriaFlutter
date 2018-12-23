import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../data/UnitPlan.dart';
import '../models/ReplacementPlan.dart';
import '../models/UnitPlan.dart';

class CourseEdit extends StatefulWidget {
  final UnitPlanSubject subject;
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

class CourseEditView extends State<CourseEdit> {
  SharedPreferences sharedPreferences;
  bool _exams = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        _exams = sharedPreferences
                .getBool(Keys.exams + widget.subject.lesson.toUpperCase()) ??
            true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return SimpleDialog(
      title: Text(
          getSubject(widget.subject.lesson) + ' ' + widget.subject.teacher),
      children: <Widget>[
        // Writing option
        CheckboxListTile(
          value: _exams,
          onChanged: (bool value) {
            setState(() {
              // Save change
              sharedPreferences.setBool(
                  Keys.exams + widget.subject.lesson.toUpperCase(), value);
              sharedPreferences.commit();
              ReplacementPlan.update(sharedPreferences);
              setState(() {
                _exams = value;
              });
              if (widget.onExamChange != null) {
                widget.onExamChange(_exams);
              }
            });
          },
          title: Text(AppLocalizations.of(context).writeExams),
        ),
      ],
    );
  }
}

class CoursesPage extends StatefulWidget {
  @override
  CoursesView createState() => CoursesView();
}

class CoursesView extends State<CoursesPage> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }

    List<UnitPlanSubject> selectedSubjects = [];

    // Get all selected subjects...
    getUnitPlan().forEach((day) => day.lessons.forEach((lesson) {
          if (lesson.subjects.length > 0) {
            int selected = sharedPreferences.getInt(Keys.unitPlan +
                    sharedPreferences.getString(Keys.grade) +
                    '-' +
                    ((lesson.subjects[0].block == '')
                        ? (getUnitPlan().indexOf(day).toString() +
                            '-' +
                            (day.lessons.indexOf(lesson)).toString())
                        : (lesson.subjects[0].block))) ??
                lesson.subjects.length;
            if (selected < lesson.subjects.length)
              selectedSubjects.add(lesson.subjects[selected]);
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

    return ListView(
        shrinkWrap: true,
        children: (courses.keys.toList().length > 0)
            ?
            // List of courses
            courses.keys
                .toList()
                .map((key) => CourseRow(
                    subjects: courses[key].toList(),
                    sharedPreferences: sharedPreferences))
                .toList()
            :
            // No subjects are selected in the unit plan
            <Widget>[
                Center(child: Text(AppLocalizations.of(context).noCourses))
              ]);
  }
}

class CourseRow extends StatefulWidget {
  final List<UnitPlanSubject> subjects;
  final SharedPreferences sharedPreferences;

  CourseRow({Key key, this.subjects, this.sharedPreferences}) : super(key: key);

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
    name = getSubject(widget.subjects[0].lesson);
    teacher = widget.subjects[0].teacher;
    course = '';
    blocks = [];
    _exams = widget.sharedPreferences
            .getBool(Keys.exams + widget.subjects[0].lesson.toUpperCase()) ??
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
