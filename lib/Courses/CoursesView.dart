import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../Rooms.dart';
import '../UnitPlan/UnitPlanData.dart' as UnitPlan;
import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanModel.dart';

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
  List<dynamic> subjects = [];

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        _exams = sharedPreferences
                .getBool(Keys.exams(widget.subject.lesson.toUpperCase())) ??
            true;
      });
      List<UnitPlanDay> days = UnitPlan.getUnitPlan();
      days.forEach((day) {
        day.lessons.forEach((lesson) {
          int _selected = sharedPreferences.getInt(Keys.unitPlan(
              sharedPreferences.getString(Keys.grade),
              block: lesson.subjects[0].block,
              day: days.indexOf(day),
              unit: day.lessons.indexOf(lesson)));
          if (lesson.subjects[_selected].lesson == widget.subject.lesson) {
            subjects.add({
              'weekday': days.indexOf(day),
              'unit': day.lessons.indexOf(lesson),
              'subject': lesson.subjects[_selected]
            });
          }
        });
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
                  Keys.exams(widget.subject.lesson.toUpperCase()), value);
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Column(
            children: subjects.map((subject) {
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
    UnitPlan.getUnitPlan().forEach((day) => day.lessons.forEach((lesson) {
          if (lesson.subjects.length > 0) {
            int selected = sharedPreferences.getInt(Keys.unitPlan(
                    sharedPreferences.getString(Keys.grade),
                    block: lesson.subjects[0].block,
                    day: UnitPlan.getUnitPlan().indexOf(day),
                    unit: day.lessons.indexOf(lesson))) ??
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
            .getBool(Keys.exams(widget.subjects[0].lesson.toUpperCase())) ??
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
