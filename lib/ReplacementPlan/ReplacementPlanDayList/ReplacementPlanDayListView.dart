import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import '../ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../ReplacementPlanRow/ReplacementPlanUnparsedRowWidget.dart';
import 'ReplacementPlanDayListWidget.dart';

class ReplacementPlanDayListView extends ReplacementPlanDayListState {
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
                Text(AppLocalizations
                    .of(context)
                    .replacementplanFor),
                Text('${widget.day.weekday}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(AppLocalizations
                    .of(context)
                    .replacementplanThe),
                Text('${widget.day.date}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations
                  .of(context)
                  .notYetExistingOnServer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
    // List of replacement plan days
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
                  Text(AppLocalizations
                      .of(context)
                      .replacementplanFor),
                  Text('${widget.day.weekday}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations
                      .of(context)
                      .replacementplanThe),
                  Text('${widget.day.date}',
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
                  Text(AppLocalizations
                      .of(context)
                      .replacementplanLastUpdated),
                  Text('${widget.day.update}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(AppLocalizations
                      .of(context)
                      .replacementplanAt),
                  Text('${widget.day.time}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ]
          ..add(widget.day.unparsed.length > 0
              ? Section(
              title: AppLocalizations
                  .of(context)
                  .unparsed,
              // Show unparsed changes...
              children: widget.day.unparsed.map((change) {
                return ReplacementPlanUnparsedRow(
                    changes: widget.day.unparsed, change: change);
              }).toList())
              : Container())
          ..addAll((!widget.sort)
              ?
          // Show all changes in a list...
          getUnsortedList(widget.day).map((change) {
            return ReplacementPlanRow(
              changes: getUnsortedList(widget.day),
              change: change,
              weekday: [
                'Montag',
                'Dienstag',
                'Mittwoch',
                'Donnerstag',
                'Freitag'
              ].indexOf(widget.day.weekday),
            );
          }).toList()
              :
          // Show the changes in three categories...
          [
            Section(
              title: AppLocalizations
                  .of(context)
                  .myChanges,
              isLast: widget.day.undefinedChanges.length == 0 &&
                  widget.day.otherChanges.length == 0,
              children: widget.day.myChanges.length > 0
                  ?
              // Show my changes
              widget.day.myChanges.map((change) {
                return ReplacementPlanRow(
                  changes: widget.day.myChanges,
                  change: change,
                  weekday: [
                    'Montag',
                    'Dienstag',
                    'Mittwoch',
                    'Donnerstag',
                    'Freitag'
                  ].indexOf(widget.day.weekday),
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
                          AppLocalizations
                              .of(context)
                              .noChanges),
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
                title: AppLocalizations
                    .of(context)
                    .undefChanges,
                children: widget.day.undefinedChanges.map((change) {
                  return ReplacementPlanRow(
                    changes: widget.day.undefinedChanges,
                    change: change,
                    weekday: [
                      'Montag',
                      'Dienstag',
                      'Mittwoch',
                      'Donnerstag',
                      'Freitag'
                    ].indexOf(widget.day.weekday),
                  );
                }).toList())
                : Container(),
            widget.day.otherChanges.length > 0
                ?
            // Show not my changes
            Section(
                isLast: true,
                title: AppLocalizations
                    .of(context)
                    .otherChanges,
                children: widget.day.otherChanges.map((change) {
                  return ReplacementPlanRow(
                    changes: widget.day.otherChanges,
                    change: change,
                    weekday: [
                      'Montag',
                      'Dienstag',
                      'Mittwoch',
                      'Donnerstag',
                      'Freitag'
                    ].indexOf(widget.day.weekday),
                  );
                }).toList())
                : Container(),
          ]),
      ),
    );
  }
}
