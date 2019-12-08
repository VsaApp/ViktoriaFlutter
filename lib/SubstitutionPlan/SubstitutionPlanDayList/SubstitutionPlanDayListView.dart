import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import '../SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import '../SubstitutionPlanRow/SubstitutionPlanUnparsedRowWidget.dart';
import 'SubstitutionPlanDayListWidget.dart';

// ignore: public_member_api_docs
class SubstitutionPlanDayListView extends SubstitutionPlanDayListState {
  @override
  Widget build(BuildContext context) {
    if (widget.day.isEmpty) {
      return Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
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
    return ListView(
      children: <Widget>[
        // For date information
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
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
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context).substitutionPlanLastUpdated),
                Text(
                    '${widget.day.updated.day}.${widget.day.updated.month}.${widget.day.updated.year}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(AppLocalizations.of(context).substitutionPlanAt),
                Text(
                    '${widget.day.updated.hour.toString().padLeft(2, '0')}:${widget.day.updated.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (widget.day
            .filterUnparsed(grade: widget.grade.toLowerCase())
            .isNotEmpty)
          Section(
              title: AppLocalizations.of(context).unparsed,
              // Show unparsed changes...
              children: widget.day.unparsed[Data.timetable.grade].map((change) {
                return SubstitutionPlanUnparsedRow(substitution: change);
              }).toList()),
        Section(
          title: AppLocalizations.of(context).myChanges,
          isLast: widget.day.undefinedChanges.isEmpty &&
              widget.day.otherChanges.isEmpty,
          children: widget.day.myChanges.isNotEmpty
              ?
              // Show my changes
              widget.day.myChanges.map((change) {
                  return SubstitutionPlanRow(
                    substitutions: widget.day.myChanges,
                    index: widget.day.myChanges.indexOf(change),
                    context: context,
                  );
                }).toList()
              :
              // Show no changes information
              <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(AppLocalizations.of(context).noChanges),
                      ),
                    ),
                  ),
                ],
        ),
        if (widget.day.undefinedChanges.isNotEmpty)
          Section(
              isLast: widget.day.otherChanges.isEmpty,
              title: AppLocalizations.of(context).undefChanges,
              children: widget.day.undefinedChanges.map((change) {
                return SubstitutionPlanRow(
                  substitutions: widget.day.undefinedChanges,
                  index: widget.day.undefinedChanges.indexOf(change),
                  context: context,
                );
              }).toList()),
        if (widget.day.otherChanges.isNotEmpty)
          Section(
              isLast: true,
              title: AppLocalizations.of(context).otherChanges,
              children: widget.day.otherChanges.map((change) {
                return SubstitutionPlanRow(
                  substitutions: widget.day.otherChanges,
                  index: widget.day.otherChanges.indexOf(change),
                  context: context,
                );
              }).toList()),
      ],
    );
  }
}
