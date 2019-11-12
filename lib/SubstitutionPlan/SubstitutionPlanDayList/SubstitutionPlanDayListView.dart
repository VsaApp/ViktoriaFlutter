import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import '../SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import '../SubstitutionPlanRow/SubstitutionPlanUnparsedRowWidget.dart';
import 'SubstitutionPlanDayListWidget.dart';

class SubstitutionPlanDayListView extends SubstitutionPlanDayListState {
  @override
  Widget build(BuildContext context) {
    if (widget.day.isEmpty) {
      return Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context).substitutionPlanFor),
                Text(
                    AppLocalizations.of(context)
                        .weekdays[widget.day.date.weekday - 1],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(AppLocalizations.of(context).substitutionPlanThe),
                Text('${widget.day.date}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context).notYetExistingOnServer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
    // List of substitution plan days
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.only(bottom: 70),
        shrinkWrap: true,
        children: <Widget>[
          // For date information
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context).substitutionPlanFor),
                  Text(
                      AppLocalizations.of(context)
                          .weekdays[widget.day.date.weekday - 1],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context).substitutionPlanThe),
                  Text(
                      '${widget.day.date.day}.${widget.day.date.month}.${widget.day.date.year}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // Update date information
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      AppLocalizations.of(context).substitutionPlanLastUpdated),
                  Text('${widget.day.updated.day}.${widget.day.updated.month}.${widget.day.updated.year}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context).substitutionPlanAt),
                  Text(
                      '${widget.day.updated.hour}:${widget.day.updated.minute}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ]
          ..add(widget.day.myUnparsed.length > 0
              ? Section(
                  title: AppLocalizations.of(context).unparsed,
                  // Show unparsed changes...
                  children:
                      widget.day.unparsed[Data.timetable.grade].map((change) {
                    return SubstitutionPlanUnparsedRow(substitution: change);
                  }).toList())
              : Container())
          ..addAll((!widget.sort)
              ?
              // Show all changes in a list...
              getUnsortedList(widget.day).map((change) {
                  return SubstitutionPlanRow(
                    changes: getUnsortedList(widget.day),
                    substitution: change,
                    weekday: widget.day.date.weekday - 1,
                  );
                }).toList()
              :
              // Show the changes in three categories...
              [
                  Section(
                    title: AppLocalizations.of(context).myChanges,
                    isLast: widget.day.undefinedChanges.length == 0 &&
                        widget.day.otherChanges.length == 0,
                    children: widget.day.myChanges.length > 0
                        ?
                        // Show my changes
                        widget.day.myChanges.map((change) {
                            return SubstitutionPlanRow(
                              changes: widget.day.myChanges,
                              substitution: change,
                              weekday: widget.day.date.weekday - 1,
                            );
                          }).toList()
                        :
                        // Show no changes information
                        <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                      AppLocalizations.of(context).noChanges),
                                ),
                              ),
                            ),
                          ],
                  ),
                  widget.day.undefinedChanges.length > 0
                      ?
                      // Show non-filtered changes
                      Section(
                          isLast: widget.day.otherChanges.length == 0,
                          title: AppLocalizations.of(context).undefChanges,
                          children: widget.day.undefinedChanges.map((change) {
                            return SubstitutionPlanRow(
                              changes: widget.day.undefinedChanges,
                              substitution: change,
                              weekday: widget.day.date.weekday - 1,
                            );
                          }).toList())
                      : Container(),
                  widget.day.otherChanges.length > 0
                      ?
                      // Show not my changes
                      Section(
                          isLast: true,
                          title: AppLocalizations.of(context).otherChanges,
                          children: widget.day.otherChanges.map((change) {
                            return SubstitutionPlanRow(
                              changes: widget.day.otherChanges,
                              substitution: change,
                              weekday: widget.day.date.weekday - 1,
                            );
                          }).toList())
                      : Container(),
                ]),
      ),
    );
  }
}
