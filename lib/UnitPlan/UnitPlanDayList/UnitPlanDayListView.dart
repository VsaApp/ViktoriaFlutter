import 'package:flutter/material.dart';
import 'UnitPlanDayListWidget.dart';
import '../../Keys.dart';
import '../../Localizations.dart';
import '../UnitPlanData.dart';
import '../UnitPlanModel.dart';
import '../UnitPlanRow/UnitPlanRowWidget.dart';
import '../../ReplacementPlan/ReplacementPlanModel.dart';
import '../../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../../Courses/CourseEdit/CourseEditWidget.dart';

class UnitPlanDayListView extends UnitPlanDayListState {
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
          // Tab bar views
          appBar: TabBar(
            controller: tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.name
                    .substring(0, 2)
                    .toUpperCase()), // Show all weekday names
              );
            }).toList(),
          ),
          body: TabBarView(
            controller: tabController,
            // List of days
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                // List of subjects
                child: ListView(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: day.lessons.map((lesson) {
                    // Check which subject is selected
                    int _selected = sharedPreferences.getInt(Keys.unitPlan(
                        grade,
                        block: lesson.subjects[0].block,
                        day: widget.days.indexOf(day),
                        unit: day.lessons.indexOf(lesson)));
                    bool nothingSelected = _selected == null;
                    if (nothingSelected) _selected = 0;
                    return GestureDetector(
                      onTap: () {
                        if (lesson.subjects.length > 1) {
                          // Show subject select dialog
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
                                            // Update unit plan
                                            setState(() {
                                              sharedPreferences.setInt(
                                                  Keys.unitPlan(grade,
                                                      block: lesson
                                                          .subjects[0].block,
                                                      day: widget.days
                                                          .indexOf(day),
                                                      unit: day.lessons
                                                          .indexOf(lesson)),
                                                  lesson.subjects
                                                      .indexOf(subject));
                                              Navigator.pop(context);
                                              ReplacementPlan.update(
                                                  sharedPreferences);
                                            });
                                            // Synchronise tags for notifications
                                            syncTags();
                                            bool _selected = (sharedPreferences
                                                    .getKeys()
                                                    .where((key) =>
                                                        key ==
                                                        Keys.exams(
                                                            sharedPreferences
                                                                .getString(
                                                                    Keys.grade),
                                                            lesson
                                                                .subjects[lesson
                                                                    .subjects
                                                                    .indexOf(
                                                                        subject)]
                                                                .lesson
                                                                .toUpperCase()))
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
                                                    AppLocalizations.of(context)
                                                        .freeLesson) {
                                              // Show writing option dialog
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
                                                        /*UnitPlan.setAllSelections(
                                                            sharedPreferences);*/
                                                      });
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: UnitPlanRow(
                                              weekday: widget.days.indexOf(day),
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
                          if (sharedPreferences.getBool(Keys.exams(
                                  sharedPreferences.getString(Keys.grade),
                                  lesson.subjects[_selected].lesson
                                      .toUpperCase())) ==
                              null) {
                            sharedPreferences.setBool(
                                Keys.exams(
                                    sharedPreferences.getString(Keys.grade),
                                    lesson.subjects[_selected].lesson
                                        .toUpperCase()),
                                true);
                            sharedPreferences.commit();
                          }
                          // Show writing option dialog
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
                          ?
                          // Show select lesson information
                          UnitPlanRow(
                              weekday: widget.days.indexOf(day),
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
                              ?
                              // Show normal subject
                              UnitPlanRow(
                                  weekday: widget.days.indexOf(day),
                                  subject: lesson.subjects[_selected],
                                  unit: day.lessons.indexOf(lesson),
                                )
                              :
                              // Show list of changes
                              Card(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        (lesson.subjects[_selected].changes
                                                    .where((change) =>
                                                        change.isMy == -1)
                                                    .length >
                                                0
                                            ? UnitPlanRow(
                                                weekday:
                                                    widget.days.indexOf(day),
                                                subject:
                                                    lesson.subjects[_selected],
                                                unit:
                                                    day.lessons.indexOf(lesson),
                                              )
                                            : Container())
                                      ]..addAll(
                                          lesson.subjects[_selected].changes
                                              .map((change) {
                                                return ReplacementPlanRow(
                                                    change: change,
                                                    changes: lesson
                                                        .subjects[_selected]
                                                        .changes);
                                              })
                                              .toList()
                                              .cast<Widget>()),
                                    ),
                                  ),
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
