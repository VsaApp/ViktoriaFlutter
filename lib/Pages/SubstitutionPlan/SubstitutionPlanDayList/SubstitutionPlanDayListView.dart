import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Widgets/GroupHeader.dart';
import 'package:viktoriaflutter/Widgets/GroupList.dart';

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
    return GroupList(groups: [
      Group(
        header: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Icon(MdiIcons.timer, color: Colors.black54),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    timeago.format(widget.day.updated.toLocal(),
                        locale:
                            AppLocalizations.of(context).locale.languageCode),
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Icon(MdiIcons.calendarToday, color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(widget.day.date.toLocal()),
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ),
        children: [],
      ),
      if (widget.day
          .filterUnparsed(grade: widget.grade.toLowerCase())
          .isNotEmpty)
        Group(
            header: GroupHeader(
                title: AppLocalizations.of(context).unparsed,
                count: widget.day.unparsed[Data.timetable.grade].length),
            children: widget.day.unparsed[Data.timetable.grade]
                .map((u) => SubstitutionPlanUnparsedRow(substitution: u))
                .toList()),

      // Show always the users changes
      Group(
        header: GroupHeader(
            title: AppLocalizations.of(context).myChanges,
            count: widget.day.myChanges.length),
        children: _getRows(widget.day.myChanges),
        emptyInfo: AppLocalizations.of(context).noChanges
      ),

      // Show undefined changes
      if (widget.day.undefinedChanges.isNotEmpty)
        Group(
          header: GroupHeader(
              title: AppLocalizations.of(context).undefChanges,
              count: widget.day.undefinedChanges.length),
          children: _getRows(widget.day.undefinedChanges),
        ),

      // Show all other changes
      if (widget.day.otherChanges.isNotEmpty)
        Group(
          header: GroupHeader(
              title: AppLocalizations.of(context).otherChanges,
              count: widget.day.otherChanges.length),
          children: _getRows(widget.day.otherChanges),
        ),
    ]);
  }

  List<SubstitutionPlanRow> _getRows(List<Substitution> substitutions) {
    return substitutions
        .map(
          (substitution) => SubstitutionPlanRow(
            context: context,
            substitutions: substitutions,
            index: substitutions.indexOf(substitution),
          ),
        )
        .toList();
  }
}
