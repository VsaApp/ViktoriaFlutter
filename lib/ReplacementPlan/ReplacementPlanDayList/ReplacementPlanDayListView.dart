import 'package:flutter/material.dart';
import 'ReplacementPlanDayListWidget.dart';
import '../../Localizations.dart';
import '../../Keys.dart';
import '../ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../../SectionWidget.dart';

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
                        child: RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: AppLocalizations.of(context)
                                      .replacementplanFor),
                              new TextSpan(
                                  text: '${day.weekday}',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
                              new TextSpan(
                                  text: AppLocalizations.of(context)
                                      .replacementplanThe),
                              new TextSpan(
                                  text: '${day.date}',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold)),
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
                        text: new TextSpan(
                          style: new TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: AppLocalizations.of(context)
                                    .replacementplanLastUpdated),
                            new TextSpan(
                                text: '${day.update}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(
                                text: AppLocalizations.of(context)
                                    .replacementplanAt),
                            new TextSpan(
                                text: '${day.time}',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )),
                  ]..addAll((!sharedPreferences
                          .getBool(Keys.sortReplacementPlan))
                      ?
                      // Show all changes in a list...
                      day.changes.map((change) {
                          return ReplacementPlanRow(
                              changes: day.changes, change: change);
                        }).toList()
                      :
                      // Show the changes in three categories...
                      [
                          Section(
                            title: AppLocalizations.of(context).myChanges,
                            isLast: day.getUndefChanges().length == 0 &&
                                day.getOtherChanges().length == 0,
                            children: day.getMyChanges().length > 0
                                ?
                                // Show my changes
                                day.getMyChanges().map((change) {
                                    return ReplacementPlanRow(
                                        changes: day.getMyChanges(),
                                        change: change);
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
                          day.getUndefChanges().length > 0
                              ?
                              // Show non-filtered changes
                              Section(
                                  isLast: day.getOtherChanges().length == 0,
                                  title:
                                      AppLocalizations.of(context).undefChanges,
                                  children: day.getUndefChanges().map((change) {
                                    return ReplacementPlanRow(
                                        changes: day.getUndefChanges(),
                                        change: change);
                                  }).toList())
                              : Container(),
                          day.getOtherChanges().length > 0
                              ?
                              // Show not my changes
                              Section(
                                  isLast: true,
                                  title:
                                      AppLocalizations.of(context).otherChanges,
                                  children: day.getOtherChanges().map((change) {
                                    return ReplacementPlanRow(
                                        changes: day.getOtherChanges(),
                                        change: change);
                                  }).toList())
                              : Container(),
                        ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
