import 'package:flutter/material.dart';

import '../../Cafetoria/CafetoriaModel.dart';
import '../../Cafetoria/DayCard/DayCardWidget.dart';
import '../../Calendar/EventCard/EventCard.dart';
import '../../Courses/CourseEdit/CourseEditWidget.dart';
import '../../Keys.dart';
import '../../Localizations.dart';
import '../../ReplacementPlan/ReplacementPlanData.dart' as Replacementplan;
import '../../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../../Selection.dart';
import '../UnitPlanSelectDialog/UnitPlanSelectDialogWidget.dart';
import '../../Tags.dart';
import '../../WorkGroups/DayCard/DayCardWidget.dart';
import '../../WorkGroups/WorkGroupsModel.dart';
import '../UnitPlanModel.dart';
import '../UnitPlanRow/UnitPlanRowWidget.dart';
import 'UnitPlanDayListWidget.dart';

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
              final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
                  GlobalKey<RefreshIndicatorState>();
              List<Widget> items = [];
              items.addAll(day.lessons.map((lesson) {
                // Check which subject is selected
                int _selected = getSelectedIndex(
                    sharedPreferences,
                    lesson.subjects,
                    widget.days.indexOf(day),
                    day.lessons.indexOf(lesson), week: day.showWeek);
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
                          return UnitPlanSelectDialog(
                            day: day, 
                            lesson: lesson, 
                            subject: lesson.subjects[_selected], 
                            sharedPreferences: sharedPreferences,
                            onSelected: () => setState(() => null),
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
                                UnitPlan.setAllSelections(sharedPreferences);
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
                              lesson: AppLocalizations.of(context).selectLesson,
                              room: '',
                              block: '',
                              unsures: 0,
                              course: '',
                              changes: [],
                              week: 'AB'),
                          unit: day.lessons.indexOf(lesson),
                          sharedPreferences: sharedPreferences,
                        )
                      : (lesson.subjects[_selected].changes.length == 0 ||
                              !sharedPreferences
                                  .getBool(Keys.showReplacementPlanInUnitPlan)
                          ?
                          // Show normal subject
                          UnitPlanRow(
                              weekday: widget.days.indexOf(day),
                              subject: lesson.subjects[_selected],
                              unit: day.lessons.indexOf(lesson),
                              sharedPreferences: sharedPreferences,
                            )
                          :
                          // Show list of changes
                          lesson.subjects[_selected]
                                      .getChanges(day.replacementPlanForWeektype , sharedPreferences)
                                      .length >
                                  0
                              ? Card(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      children: [
                                        (lesson.subjects[_selected].unsures > 0
                                            ? UnitPlanRow(
                                                weekday:
                                                    widget.days.indexOf(day),
                                                subject:
                                                    lesson.subjects[_selected],
                                                unit:
                                                    day.lessons.indexOf(lesson),
                                                sharedPreferences:
                                                    sharedPreferences,
                                              )
                                            : Container())
                                      ]..addAll(lesson.subjects[_selected]
                                          .getChanges(day.replacementPlanForWeektype, sharedPreferences)
                                          .map((change) {
                                            return ReplacementPlanRow(
                                              change: change,
                                              changes: lesson
                                                  .subjects[_selected]
                                                  .getChanges(day.replacementPlanForWeektype,
                                                      sharedPreferences),
                                              weekday: widget.days.indexOf(day),
                                              sharedPreferences:
                                                  sharedPreferences,
                                            );
                                          })
                                          .toList()
                                          .cast<Widget>()),
                                    ),
                                  ),
                                )
                              : UnitPlanRow(
                                  weekday: widget.days.indexOf(day),
                                  subject: lesson.subjects[_selected],
                                  unit: day.lessons.indexOf(lesson),
                                  sharedPreferences: sharedPreferences,
                                ))),
                );
              }).toList());
              if (showCalendar) {
                getEventsForWeekday(widget.days.indexOf(day)).forEach((event) {
                  items.add(Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: EventCard(
                      event: event,
                    ),
                  ));
                });
              }
              if (showCafetoria) {
                items.add(Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CafetoriaDayCard(
                    day: Cafetoria.menues.days[widget.days.indexOf(day)],
                    showWeekday: false,
                  ),
                ));
              }
              if (showWorkGroups) {
                items.add(Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: WorkGroupsDayCard(
                    day: WorkGroups.days[widget.days.indexOf(day)],
                    showWeekday: false,
                  ),
                ));
              }
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                // List of subjects
                child: RefreshIndicator(
                  onRefresh: update,
                  key: refreshIndicatorKey,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    shrinkWrap: true,
                    children: items,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
