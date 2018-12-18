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
import 'Courses.dart';
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
              content: Text(AppLocalizations.of(context).oldDataIsShown),
              action: SnackBarAction(
                label: AppLocalizations.of(context).ok,
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

class UnitPlanDayListState extends State<UnitPlanDayList>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  String _grade = '';
  TabController _tabController;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        _grade = sharedPreferences.getString(Keys.grade);
      });
    });
    _tabController = new TabController(vsync: this, length: widget.days.length);
    int weekday = DateTime.now().weekday - 1;
    bool over = false;
    if (weekday > 4) {
      weekday = 0;
    } else if (widget.days[weekday].lessons.length > 0) {
      if (DateTime.now().isAfter(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
      ).add(Duration(
          minutes: [
        60,
        130,
        210,
        280,
        360,
        420,
        480,
        545
      ][widget.days[weekday].lessons.length - 1])))) {
        over = true;
      }
    }
    if (over) {
      weekday++;
    }
    if (weekday > 4) {
      weekday = 0;
    }
    _tabController.animateTo(weekday);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            controller: _tabController,
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
            controller: _tabController,
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
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
                                      AppLocalizations.of(context).nUnit),
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
                                            syncTags();
                                            bool _selected = (sharedPreferences
                                                .getKeys()
                                                .where((key) =>
                                            key ==
                                                Keys.exams +
                                                    lesson
                                                        .subjects[lesson
                                                        .subjects
                                                        .indexOf(
                                                        subject)]
                                                        .lesson)
                                                .length >
                                                0);
                                            if (!_selected &&
                                                lesson
                                                    .subjects[lesson
                                                    .subjects
                                                    .indexOf(subject)]
                                                    .block !=
                                                    null &&
                                                lesson
                                                    .subjects[lesson
                                                    .subjects
                                                    .indexOf(subject)]
                                                    .lesson !=
                                                    AppLocalizations
                                                        .of(context)
                                                        .freeLesson) {
                                              showDialog<String>(
                                                context: context1,
                                                barrierDismissible: true,
                                                builder:
                                                    (BuildContext context2) {
                                                  return CourseEdit(
                                                    subject: lesson.subjects[
                                                    lesson.subjects
                                                        .indexOf(subject)],
                                                    blocks: [
                                                      lesson
                                                          .subjects[lesson
                                                          .subjects
                                                          .indexOf(subject)]
                                                          .block
                                                    ],
                                                    onExamChange: (_) {
                                                      setState(() {
                                                        UnitPlan
                                                            .setAllSelections(
                                                            sharedPreferences);
                                                      });
                                                    },
                                                  );
                                                },
                                              );
                                            }
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
                                AppLocalizations.of(context).freeLesson &&
                            lesson.subjects[_selected].lesson !=
                                AppLocalizations.of(context).lunchBreak &&
                            !nothingSelected) {
                          showDialog<String>(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context1) {
                              return CourseEdit(
                                subject: lesson.subjects[_selected],
                                blocks: [lesson.subjects[_selected].block],
                                onExamChange: (_) {
                                  setState(() {
                                    UnitPlan.setAllSelections(
                                        sharedPreferences);
                                  });
                                },
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
                                      AppLocalizations.of(context).selectLesson,
                                  room: '',
                                  block: ''),
                              unit: day.lessons.indexOf(lesson),
                            )
                          : (lesson.subjects[_selected].changes.length == 0 ||
                                  !sharedPreferences.getBool(
                                      Keys.showReplacementPlanInUnitPlan)
                              ? UnitPlanRow(
                                  subject: lesson.subjects[_selected],
                                  unit: day.lessons.indexOf(lesson),
                                )
                          : Column(
                        children: lesson.subjects[_selected].changes
                            .map((change) {
                          return ReplacementPlanRow(
                              change: change,
                              changes: lesson
                                  .subjects[_selected].changes);
                        })
                            .toList()
                            .cast<Widget>(),
                      ))),
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
