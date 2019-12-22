import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Cafetoria/DayCard/DayCardWidget.dart';
import 'package:viktoriaflutter/Calendar/EventCard/EventCard.dart';
import 'package:viktoriaflutter/Courses/CourseEdit/CourseEditWidget.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/WorkGroups/DayCard/DayCardWidget.dart';
import 'package:viktoriaflutter/Timetable/TimetableRow/TimetableRowWidget.dart';
import 'package:viktoriaflutter/Timetable/TimetableSelectDialog/TimetableSelectDialogWidget.dart';
import 'package:viktoriaflutter/Timetable/TimetableDayList/TimetableDayListWidget.dart';

// ignore: public_member_api_docs
class TimetableDayListView extends TimetableDayListState {
  @override
  Widget build(BuildContext context) {
    final List<Widget> items = widget.day.units.map((unit) {
      // Check which subject is selected
      int _selected = getSelectedIndex(
        unit.subjects,
        week: widget.day.showWeek,
      );
      final bool nothingSelected = _selected == null;
      if (nothingSelected) {
        _selected = 0;
      }
      final TimetableSubject selected = unit.subjects[_selected];
      final List<SubstitutionPlanDay> sDays = Data.substitutionPlan.days
          .where((day) => day.date.weekday - 1 == widget.day.day)
          .toList();
      final SubstitutionPlanDay sDay = sDays.isNotEmpty ? sDays[0] : null;
      final List<Substitution> substitutions =
          selected.getSubstitutions().where((substitution) {
        return !substitution.isExam || sDay.isMySubstitution(substitution);
      }).toList();
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
              selected.subjectID != AppLocalizations.of(context).freeLesson &&
              selected.subjectID != AppLocalizations.of(context).lunchBreak &&
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
        child: nothingSelected
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
                            subject: TimetableSubject(
                                id: 'selection',
                                unit: unit.unit,
                                day: unit.day,
                                teacherID: '',
                                subjectID:
                                    AppLocalizations.of(context).selectLesson,
                                roomID: '',
                                block: '',
                                courseID: ''),
                          ),
                        ]))))
            : (substitutions.isEmpty ||
                    !Storage.getBool(Keys.showSubstitutionPlanInTimetable)
                ?
                // Show normal subject
                Padding(
                    padding: EdgeInsets.only(left: 2.5, right: 2.5),
                    child: TimetableRow(
                      subject: selected,
                    ),
                  )
                :
                // Show list of changes
                substitutions.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                            top: widget.day.units.indexOf(unit) == 0 ? 10 : 0),
                        child: Card(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          margin: EdgeInsets.only(left: 0, right: 0, bottom: 4, top: 4),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                if (substitutions[0].isExam && substitutions.length == 1) TimetableRow(
                                  subject: selected,
                                ),
                                ...substitutions
                                  .map<Widget>((change) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 2.5, right: 2.5),
                                      child: SubstitutionPlanRow(
                                        index: substitutions.indexOf(change),
                                        substitutions: substitutions,
                                        context: context,
                                        showUnit: !(substitutions[0].isExam && substitutions.length == 1),
                                      ),
                                    );
                                  })
                                  .toList()
                              ]
                            ),
                          ),
                        ))
                    : TimetableRow(
                        subject: selected,
                      )),
      );
    }).toList();
    final List<Widget> infoItems = [];
    if (showCalendar) {
      getEventsForWeekday(widget.day.day).forEach((event) {
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
          day: Data.cafetoria.days[widget.day.day],
          showWeekday: false,
        ),
      ));
    }
    if (showWorkGroups) {
      infoItems.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: WorkGroupsDayCard(
          day: Data.workGroups.days[widget.day.day],
          showWeekday: false,
        ),
      ));
    }
    if (infoItems.isNotEmpty) {
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
                                stops: const [
                                  0,
                                  0.6,
                                  1
                                ],
                                colors: const [
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
                                    borderRadius: BorderRadius.circular(16),
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
        padding: EdgeInsets.only(bottom: 20),
        children: items,
      );
    }
  }
}
