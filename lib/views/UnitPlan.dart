import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../Times.dart';
import '../data/UnitPlan.dart';
import '../models/ReplacementPlan.dart';
import '../models/UnitPlan.dart';
import 'ReplacementPlan.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  bool _offlineShown = false;

  Future<bool> get checkOnline async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_offlineShown) {
      checkOnline.then((online) {
        _offlineShown = true;
        if (!online) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations
                  .of(context)
                  .oldDataIsShown),
              action: SnackBarAction(
                label: AppLocalizations
                    .of(context)
                    .ok,
                onPressed: () {},
              ),
            ),
          );
        }
      });
    }
    return Column(children: <Widget>[UnitPlanDayList(days: getUnitPlan())]);
  }
}

class UnitPlanDayList extends StatefulWidget {
  final List<UnitPlanDay> days;

  UnitPlanDayList({Key key, this.days}) : super(key: key);

  @override
  UnitPlanDayListState createState() => UnitPlanDayListState();
}

class UnitPlanDayListState extends State<UnitPlanDayList> {
  SharedPreferences sharedPreferences;
  String _grade = '';

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        _grade = sharedPreferences.getString(Keys.grade);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return DefaultTabController(
      length: widget.days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.name.substring(0, 2).toUpperCase()),
              );
            }).toList(),
          ),
          body: TabBarView(
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: ListView(
                  shrinkWrap: true,
                  children: day.lessons.map((lesson) {
                    int _selected = sharedPreferences.getInt(Keys.unitPlan +
                        _grade +
                        '-' +
                        (lesson.subjects[0].block == ''
                            ? widget.days.indexOf(day).toString() +
                            '-' +
                            day.lessons.indexOf(lesson).toString()
                            : lesson.subjects[0].block));
                    bool nothingSelected = _selected == null;
                    if (nothingSelected) _selected = 0;
                    return GestureDetector(
                      onTap: () {
                        if (lesson.subjects.length > 1) {
                          showDialog<String>(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context1) {
                                return SimpleDialog(
                                  title: Text((day.lessons.indexOf(lesson) + 1)
                                      .toString() +
                                      AppLocalizations
                                          .of(context)
                                          .nUnit),
                                  children: lesson.subjects
                                      .map((subject) {
                                    return SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          sharedPreferences.setInt(
                                              Keys.unitPlan +
                                                  _grade +
                                                  '-' +
                                                  (lesson.subjects[0]
                                                      .block ==
                                                      null
                                                      ? widget.days
                                                      .indexOf(day)
                                                      .toString() +
                                                      '-' +
                                                      day.lessons
                                                          .indexOf(
                                                          lesson)
                                                          .toString()
                                                      : lesson.subjects[0]
                                                      .block),
                                              lesson.subjects
                                                  .indexOf(subject));
                                          Navigator.pop(context);
                                          ReplacementPlan.updateFilter(day,
                                              lesson, sharedPreferences);
                                        });
                                      },
                                      child: UnitPlanRow(
                                          subject: subject,
                                          unit: day.lessons.indexOf(lesson),
                                          showUnit: false),
                                    );
                                  })
                                      .toList()
                                      .cast<Widget>(),
                                );
                              });
                        }
                      },
                      onLongPress: () {
                        if (lesson.subjects[_selected].block != null &&
                            lesson.subjects[_selected].lesson !=
                                AppLocalizations
                                    .of(context)
                                    .freeLesson &&
                            lesson.subjects[_selected].lesson !=
                                AppLocalizations
                                    .of(context)
                                    .lunchBreak) {
                          showDialog<String>(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context1) {
                              bool _exams = sharedPreferences.getBool(
                                  Keys.exams +
                                      lesson.subjects[_selected].lesson);
                              return SimpleDialog(
                                title: Text(getSubject(
                                    lesson.subjects[_selected].lesson) +
                                    ' ' +
                                    lesson.subjects[_selected].teacher),
                                children: <Widget>[
                                  CheckboxListTile(
                                    value: (_exams == null) ? true : _exams,
                                    onChanged: (bool value) {
                                      setState(() {
                                        sharedPreferences.setBool(
                                            Keys.exams +
                                                lesson
                                                    .subjects[_selected].lesson,
                                            value);
                                        sharedPreferences.commit();
                                        ReplacementPlan.update(
                                            sharedPreferences);
                                        Navigator.pop(context);
                                      });
                                    },
                                    title: new Text(AppLocalizations
                                        .of(context)
                                        .writeExams),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: (nothingSelected
                          ? UnitPlanRow(
                        subject: UnitPlanSubject(
                            teacher: '',
                            lesson:
                            AppLocalizations
                                .of(context)
                                .selectLesson,
                            room: '',
                            block: ''),
                        unit: day.lessons.indexOf(lesson),
                      )
                          : (lesson.subjects[_selected].change == null ||
                          !sharedPreferences.getBool(
                              Keys.showReplacementPlanInUnitPlan)
                          ? UnitPlanRow(
                        subject: lesson.subjects[_selected],
                        unit: day.lessons.indexOf(lesson),
                      )
                          : ReplacementPlanRow(
                          change: lesson.subjects[_selected].change,
                          changes: [
                            lesson.subjects[_selected].change
                          ]))),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class UnitPlanRow extends StatelessWidget {
  const UnitPlanRow({
    Key key,
    this.subject,
    this.unit,
    this.showUnit = true,
  }) : super(key: key);

  final UnitPlanSubject subject;
  final int unit;
  final bool showUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                width: (showUnit) ? constraints.maxWidth * 0.1 : 0,
                child: Text(
                  ((unit != 5 && showUnit) ? (unit + 1).toString() : ''),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: constraints.maxWidth * 0.75,
                    child: (unit != 5
                        ? Text(
                      getSubject(subject.lesson),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                        : Center(
                      child: Text(
                        getSubject(subject.lesson),
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    )),
                  ),
                  Container(
                    width: constraints.maxWidth * 0.75,
                    child: Text(
                      (unit != 5 ? times[unit] : ''),
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
                    width: (showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(subject.teacher),
                  ),
                  Container(
                    width: (showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(subject.room),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
