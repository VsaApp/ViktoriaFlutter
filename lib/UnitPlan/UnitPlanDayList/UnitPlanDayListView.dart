import 'package:flutter/material.dart';

import '../../Cafetoria/CafetoriaModel.dart';
import '../../Cafetoria/DayCard/DayCardWidget.dart';
import '../../Calendar/EventCard/EventCard.dart';
import '../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../WorkGroups/DayCard/DayCardWidget.dart';
import '../../WorkGroups/WorkGroupsModel.dart';
import '../UnitPlanModel.dart';
import '../UnitPlanRow/UnitPlanRowWidget.dart';
import '../UnitPlanSelectDialog/UnitPlanSelectDialogWidget.dart';
import 'UnitPlanDayListWidget.dart';

class UnitPlanDayListView extends UnitPlanDayListState {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.addAll(widget.day.lessons.map((lesson) {
      // Check which subject is selected
      int _selected = getSelectedIndex(
          lesson.subjects, widget.dayIndex, widget.day.lessons.indexOf(lesson),
          week: widget.day.showWeek);
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
                    day: widget.day,
                    lesson: lesson,
                    onSelected: () => setState(() => null),
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
                      .lunchBreak &&
              !nothingSelected) {
            if (Storage.getBool(Keys.exams(Storage.getString(Keys.grade),
                lesson.subjects[_selected].lesson.toUpperCase())) ==
                null) {
              Storage.setBool(
                  Keys.exams(Storage.getString(Keys.grade),
                      lesson.subjects[_selected].lesson.toUpperCase()),
                  true);
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
                      UnitPlan.setAllSelections();
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
            Padding(
                padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: widget.day.lessons.indexOf(lesson) == 0 ? 10 : 0),
                child: Card(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(children: [
                          UnitPlanRow(
                            weekday: widget.dayIndex,
                            subject: UnitPlanSubject(
                                teacher: '',
                                lesson:
                                AppLocalizations
                                    .of(context)
                                    .selectLesson,
                                room: '',
                                block: '',
                                unsures: 0,
                                course: '',
                                changes: [],
                                week: 'AB'),
                            unit: widget.day.lessons.indexOf(lesson),
                          ),
                        ]))))
            : (lesson.subjects[_selected].changes.length == 0 ||
                    !Storage.getBool(Keys.showReplacementPlanInUnitPlan)
                ?
                // Show normal subject
                Padding(
                  padding: EdgeInsets.only(left: 2.5, right: 2.5),
                  child: UnitPlanRow(
                    weekday: widget.dayIndex,
                    subject: lesson.subjects[_selected],
                    unit: widget.day.lessons.indexOf(lesson),
                  ),
                )
            :
                // Show list of changes
                lesson.subjects[_selected]
                    .getChanges(widget.day.replacementPlanForWeektype)
                            .length >
                        0
                    ? Padding(
                    padding: EdgeInsets.only(
                        left: 0,
                        right: 0,
                        top: widget.day.lessons.indexOf(lesson) == 0
                            ? 10
                            : 0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                (lesson.subjects[_selected].unsures > 0 ||
                                    (lesson.subjects[_selected]
                                        .getChanges(widget.day
                                        .replacementPlanForWeektype)
                                        .map((change) => change.isExam)
                                        .toList()
                                        .contains(true) &&
                                        lesson.subjects[_selected]
                                            .getChanges(widget.day
                                            .replacementPlanForWeektype)
                                            .where((change) =>
                                        !change.isExam)
                                            .toList()
                                            .length ==
                                            0)
                                    ? UnitPlanRow(
                                        weekday: widget.dayIndex,
                                        subject: lesson.subjects[_selected],
                                  unit:
                                  widget.day.lessons.indexOf(lesson),
                                      )
                                    : Container())
                              ]
                                ..addAll(lesson.subjects[_selected]
                                    .getChanges(
                                    widget.day.replacementPlanForWeektype)
                                  .map((change) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 2.5, right: 2.5),
                                      child: ReplacementPlanRow(
                                        showUnit: !(lesson.subjects[_selected]
                                            .unsures >
                                            0 ||
                                            (lesson.subjects[_selected]
                                                .getChanges(widget.day
                                                .replacementPlanForWeektype)
                                                .map((change) =>
                                            change.isExam)
                                                .toList()
                                                .contains(true) &&
                                                lesson.subjects[_selected]
                                                    .getChanges(widget.day
                                                    .replacementPlanForWeektype)
                                                    .where((change) =>
                                                !change.isExam)
                                                    .toList()
                                                    .length ==
                                                    0)),
                                        change: change,
                                        changes: lesson.subjects[_selected]
                                            .getChanges(widget.day
                                            .replacementPlanForWeektype),
                                        weekday: widget.dayIndex,
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>()),
                            ),
                          ),
                        ))
                    : UnitPlanRow(
                        weekday: widget.dayIndex,
                        subject: lesson.subjects[_selected],
                        unit: widget.day.lessons.indexOf(lesson),
                      ))),
      );
    }).toList());
    if (showCalendar) {
      getEventsForWeekday(widget.dayIndex).forEach((event) {
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
          day: Cafetoria.menues.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    if (showWorkGroups) {
      items.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: WorkGroupsDayCard(
          day: WorkGroups.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    return ListView(
      shrinkWrap: true,
      children: items,
    );
  }
}
