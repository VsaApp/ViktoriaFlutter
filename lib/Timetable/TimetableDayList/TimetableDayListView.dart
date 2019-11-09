import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../Cafetoria/CafetoriaModel.dart';
import '../../Cafetoria/DayCard/DayCardWidget.dart';
import '../../Calendar/EventCard/EventCard.dart';
import '../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../../SubstitutionPlan/SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../WorkGroups/DayCard/DayCardWidget.dart';
import '../../WorkGroups/WorkGroupsModel.dart';
import '../TimetableModel.dart';
import '../TimetableRow/TimetableRowWidget.dart';
import '../TimetableSelectDialog/TimetableSelectDialogWidget.dart';
import 'TimetableDayListWidget.dart';

class TimetableDayListView extends TimetableDayListState {
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
                  return TimetableSelectDialog(
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
                      Timetable.setAllSelections();
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
                          TimetableRow(
                            weekday: widget.dayIndex,
                            subject: TimetableSubject(
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
                    !Storage.getBool(Keys.showSubstitutionPlanInTimetable)
                ?
                // Show normal subject
                Padding(
                  padding: EdgeInsets.only(left: 2.5, right: 2.5),
                  child: TimetableRow(
                    weekday: widget.dayIndex,
                    subject: lesson.subjects[_selected],
                    unit: widget.day.lessons.indexOf(lesson),
                  ),
                )
            :
                // Show list of changes
                lesson.subjects[_selected]
                    .getChanges(widget.day.substitutionPlanForWeektype)
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
                                        .substitutionPlanForWeektype)
                                        .map((change) => change.isExam)
                                        .toList()
                                        .contains(true) &&
                                        lesson.subjects[_selected]
                                            .getChanges(widget.day
                                            .substitutionPlanForWeektype)
                                            .where((change) =>
                                        !change.isExam)
                                            .toList()
                                            .length ==
                                            0)
                                    ? TimetableRow(
                                        weekday: widget.dayIndex,
                                        subject: lesson.subjects[_selected],
                                  unit:
                                  widget.day.lessons.indexOf(lesson),
                                      )
                                    : Container())
                              ]
                                ..addAll(lesson.subjects[_selected]
                                    .getChanges(
                                    widget.day.substitutionPlanForWeektype)
                                  .map((change) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 2.5, right: 2.5),
                                      child: SubstitutionPlanRow(
                                        showUnit: !(lesson.subjects[_selected]
                                            .unsures >
                                            0 ||
                                            (lesson.subjects[_selected]
                                                .getChanges(widget.day
                                                .substitutionPlanForWeektype)
                                                .map((change) =>
                                            change.isExam)
                                                .toList()
                                                .contains(true) &&
                                                lesson.subjects[_selected]
                                                    .getChanges(widget.day
                                                    .substitutionPlanForWeektype)
                                                    .where((change) =>
                                                !change.isExam)
                                                    .toList()
                                                    .length ==
                                                    0)),
                                        change: change,
                                        changes: lesson.subjects[_selected]
                                            .getChanges(widget.day
                                            .substitutionPlanForWeektype),
                                        weekday: widget.dayIndex,
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>()),
                            ),
                          ),
                        ))
                    : TimetableRow(
                        weekday: widget.dayIndex,
                        subject: lesson.subjects[_selected],
                        unit: widget.day.lessons.indexOf(lesson),
                      ))),
      );
    }).toList());
    List<Widget> infoItems = [];
    if (showCalendar) {
      getEventsForWeekday(widget.dayIndex).forEach((event) {
        infoItems.add(Padding(
          padding: EdgeInsets.only(top: 10),
          child: EventCard(
            event: event,
          ),
        ));
      });
    }
    if (showCafetoria) {
      infoItems.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: CafetoriaDayCard(
          day: Cafetoria.menues.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    if (showWorkGroups) {
      infoItems.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: WorkGroupsDayCard(
          day: WorkGroups.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    if (infoItems.length > 0) {
      return Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 110),
            shrinkWrap: true,
            children: items,
          ),
          SlidingUpPanel(
            controller: panelController,
            minHeight: 100,
            backdropEnabled: true,
            panel: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (panelController.isPanelClosed()) {
                            panelController.open();
                          }
                          else if (panelController.isPanelOpen()) {
                            panelController.close();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0, 0.6, 1],
                              colors: [
                                Color.fromARGB(20, 100, 100, 100),
                                Color.fromARGB(10, 100, 100, 100),
                                Color.fromARGB(0, 100, 100, 100)
                              ]
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 7, bottom: 10),
                              child: SizedBox(
                                height: 6,
                                width: 70,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ),
                      SizedBox(
                        height: constraints.maxHeight - 23,
                        child: ListView(
                          children: infoItems,
                        )
                      )
                    ],
                  )
                );
              },
            )
          )
        ]
      );
    }
    else {
      return ListView(
        shrinkWrap: true,
        children: items,
      );
    }
  }
}
