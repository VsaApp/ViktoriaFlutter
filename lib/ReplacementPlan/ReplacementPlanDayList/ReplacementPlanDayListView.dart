import 'package:flutter/material.dart';

import '../../Localizations.dart';
import '../../SectionWidget.dart';
import '../ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../ReplacementPlanRow/ReplacementPlanUnparsedRowWidget.dart';
import 'ReplacementPlanDayListWidget.dart';

class ReplacementPlanDayListView extends ReplacementPlanDayListState {
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
          appBar: TabBar(
            controller: tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday),
              );
            }).toList(),
          ),
          // Tab bar views
          body: TabBarView(
            controller: tabController,
            children: widget.days.map((day) {
              final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
              GlobalKey<RefreshIndicatorState>();
              // List of replacement plan days
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: RefreshIndicator(
                  onRefresh: update,
                  key: refreshIndicatorKey,
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 70),
                    shrinkWrap: true,
                    children: <Widget>[
                      // For date information
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: AppLocalizations.of(context)
                                        .replacementplanFor),
                                TextSpan(
                                    text: '${day.weekday}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: AppLocalizations.of(context)
                                        .replacementplanThe),
                                TextSpan(
                                    text: '${day.date}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Update date iformation
                      Center(
                          child: Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: AppLocalizations.of(context)
                                      .replacementplanLastUpdated),
                              TextSpan(
                                  text: '${day.update}',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: AppLocalizations.of(context)
                                      .replacementplanAt),
                              TextSpan(
                                  text: '${day.time}',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )),
                    ]
                      ..add(day.unparsed.length > 0
                          ? Section(
                              title: AppLocalizations.of(context).unparsed,
                              // Show unparsed changes...
                              children: day.unparsed.map((change) {
                                return ReplacementPlanUnparsedRow(
                                    changes: day.unparsed, change: change);
                              }).toList())
                          : Container())
                      ..addAll((!widget.sort)
                          ?
                          // Show all changes in a list...
                      getUnsortedList(day).map((change) {
                              return ReplacementPlanRow(
                                changes: getUnsortedList(day),
                                change: change,
                                weekday: [
                                  'Montag',
                                  'Dienstag',
                                  'Mittwoch',
                                  'Donnerstag',
                                  'Freitag'
                                ].indexOf(day.weekday),
                                sharedPreferences: sharedPreferences,
                              );
                            }).toList()
                          :
                          // Show the changes in three categories...
                          [
                              Section(
                                title: AppLocalizations.of(context).myChanges,
                                isLast: day.undefinedChanges.length == 0 &&
                                    day.otherChanges.length == 0,
                                children: day.myChanges.length > 0
                                    ?
                                    // Show my changes
                                    day.myChanges.map((change) {
                                        return ReplacementPlanRow(
                                          changes: day.myChanges,
                                          change: change,
                                          weekday: [
                                            'Montag',
                                            'Dienstag',
                                            'Mittwoch',
                                            'Donnerstag',
                                            'Freitag'
                                          ].indexOf(day.weekday),
                                          sharedPreferences: sharedPreferences,
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
                                                  AppLocalizations.of(context)
                                                      .noChanges),
                                            ),
                                          ),
                                        ),
                                      ],
                              ),
                              day.undefinedChanges.length > 0
                                  ?
                                  // Show non-filtered changes
                                  Section(
                                      isLast: day.otherChanges.length == 0,
                                      title: AppLocalizations.of(context)
                                          .undefChanges,
                                      children:
                                          day.undefinedChanges.map((change) {
                                        return ReplacementPlanRow(
                                          changes: day.undefinedChanges,
                                          change: change,
                                          weekday: [
                                            'Montag',
                                            'Dienstag',
                                            'Mittwoch',
                                            'Donnerstag',
                                            'Freitag'
                                          ].indexOf(day.weekday),
                                          sharedPreferences: sharedPreferences,
                                        );
                                      }).toList())
                                  : Container(),
                              day.otherChanges.length > 0
                                  ?
                                  // Show not my changes
                                  Section(
                                      isLast: true,
                                      title: AppLocalizations.of(context)
                                          .otherChanges,
                                      children: day.otherChanges.map((change) {
                                        return ReplacementPlanRow(
                                          changes: day.otherChanges,
                                          change: change,
                                          weekday: [
                                            'Montag',
                                            'Dienstag',
                                            'Mittwoch',
                                            'Donnerstag',
                                            'Freitag'
                                          ].indexOf(day.weekday),
                                          sharedPreferences: sharedPreferences,
                                        );
                                      }).toList())
                                  : Container(),
                            ]),
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
