import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../data/UnitPlan.dart';
import '../models/ReplacementPlan.dart';
import '../models/UnitPlan.dart';

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
                    ((lesson.subjects[0].block == null)
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
            ? courses.keys
                .toList()
                .map((key) => CourseRow(
                    subjects: courses[key].toList(),
                    sharedPreferences: sharedPreferences))
                .toList()
            : <Widget>[
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
    _exams = widget.sharedPreferences.getBool(Keys.exams + name) ?? true;

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
                        Container(
                          width: constraints.maxWidth * 0.20,
                          child: Text(
                            course,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
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
                        Container(
                          width: constraints.maxWidth * 0.10,
                          child: IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: AppLocalizations.of(context).edit,
                              onPressed: () {
                                showDialog<String>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context1) {
                                    return SimpleDialog(
                                      title: Text(name + ' ' + teacher),
                                      children: <Widget>[
                                        CheckboxListTile(
                                          value: _exams,
                                          onChanged: (bool value) {
                                            setState(() {
                                              blocks.forEach((block) {
                                                widget.sharedPreferences
                                                    .setBool(Keys.exams + name,
                                                        value);
                                              });
                                              widget.sharedPreferences.commit();
                                              ReplacementPlan.update(
                                                  widget.sharedPreferences);
                                              _exams = value;
                                              Navigator.pop(context);
                                            });
                                          },
                                          title: new Text(
                                              AppLocalizations.of(context)
                                                  .writeExams),
                                        ),
                                      ],
                                    );
                                  },
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
