import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import '../../Cafetoria/DayCard/DayCardWidget.dart';
import '../../Calendar/EventCard/EventCard.dart';
import '../../Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../../SubstitutionPlan/SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../WorkGroups/DayCard/DayCardWidget.dart';
import '../TimetableRow/TimetableRowWidget.dart';
import '../TimetableSelectDialog/TimetableSelectDialogWidget.dart';
import 'TimetableDayListWidget.dart';

class TimetableDayListView extends TimetableDayListState {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.addAll(widget.day.units.map((unit) {
      // Check which subject is selected
      int _selected = getSelectedIndex(
        unit.subjects,
        week: widget.day.showWeek,
      );
      bool nothingSelected = _selected == null;
      if (nothingSelected) _selected = 0;
      TimetableSubject selected = unit.subjects[_selected];
      return GestureDetector(
        onTap: () {
          if (unit.subjects.length > 1) {
            // Show subject select dialog
            showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context1) {
                  return TimetableSelectDialog(
                    day: widget.day,
                    unit: unit,
                    onSelected: () => setState(() => null),
                  );
                });
          }
        },
        onLongPress: () {
          if (selected.block != null &&
              selected.subjectID !=
                  AppLocalizations.of(context).freeLesson &&
              selected.subjectID !=
                  AppLocalizations.of(context).lunchBreak &&
              !nothingSelected) {
            if (!selected.examIsSet) {
              selected.writeExams = true;
            }
            // Show writing option dialog
            showDialog<String>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context1) {
                return CourseEdit(
                  subject: selected,
                  blocks: [selected.block],
                  onExamChange: (_) {
                    setState(() {
                      Data.timetable.setAllSelections();
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
                    top: widget.day.units.indexOf(unit) == 0 ? 10 : 0),
                child: Card(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(children: [
                          TimetableRow(
                            weekday: widget.dayIndex,
                            subject: TimetableSubject(
                                id: 'selection',
                                unit: unit.unit,
                                day: unit.day,
                                teacherID: '',
                                subjectID:
                                    AppLocalizations.of(context).selectLesson,
                                roomID: '',
                                block: '',
                                courseID: '',
                                week: 2),
                            unit: widget.day.units.indexOf(unit),
                          ),
                        ]))))
            : (selected.getSubstitutions().length == 0 ||
                    !Storage.getBool(Keys.showSubstitutionPlanInTimetable)
                ?
                // Show normal subject
                Padding(
                    padding: EdgeInsets.only(left: 2.5, right: 2.5),
                    child: TimetableRow(
                      weekday: widget.dayIndex,
                      subject: selected,
                      unit: widget.day.units.indexOf(unit),
                    ),
                  )
                :
                // Show list of changes
                selected.getSubstitutions().length > 0
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            top: widget.day.units.indexOf(unit) == 0 ? 10 : 0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: selected
                                  .getSubstitutions()
                                  .map((change) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 2.5, right: 2.5),
                                      child: SubstitutionPlanRow(
                                        substitution: change,
                                        changes: selected
                                            .getSubstitutions(),
                                        weekday: widget.dayIndex,
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ),
                          ),
                        ))
                    : TimetableRow(
                        weekday: widget.dayIndex,
                        subject: selected,
                        unit: widget.day.units.indexOf(unit),
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
          day: Data.cafetoria.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    if (showWorkGroups) {
      infoItems.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: WorkGroupsDayCard(
          day: Data.workGroups.days[widget.dayIndex],
          showWeekday: false,
        ),
      ));
    }
    if (infoItems.length > 0) {
      return Stack(children: [
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
                          } else if (panelController.isPanelOpen()) {
                            panelController.close();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [
                                  0,
                                  0.6,
                                  1
                                ],
                                colors: [
                                  Color.fromARGB(20, 100, 100, 100),
                                  Color.fromARGB(10, 100, 100, 100),
                                  Color.fromARGB(0, 100, 100, 100)
                                ]),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 7, bottom: 10),
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
                        )),
                    SizedBox(
                        height: constraints.maxHeight - 23,
                        child: ListView(
                          children: infoItems,
                        ))
                  ],
                ));
              },
            ))
      ]);
    } else {
      return ListView(
        shrinkWrap: true,
        children: items,
      );
    }
  }
}
