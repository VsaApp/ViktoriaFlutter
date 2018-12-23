import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './ReplacementPlan.dart';
import '../Localizations.dart';
import '../data/ReplacementPlan.dart';
import '../models/ReplacementPlan.dart';

class BrotherSisterReplacementPlanPage extends StatefulWidget {
  final String grade;

  BrotherSisterReplacementPlanPage({Key key, @required this.grade})
      : super(key: key);

  @override
  BrotherSisterReplacementPlanView createState() =>
      BrotherSisterReplacementPlanView();
}

class BrotherSisterReplacementPlanView
    extends State<BrotherSisterReplacementPlanPage> {
  List<ReplacementPlanDay> days;

  @override
  void initState() {
    // Download the replacementplan temp...
    download(widget.grade, alreadyLoad: false).then((_) {
      load(widget.grade, temp: true, setOnlyColor: true, setFilter: false)
          .then((d) {
        setState(() {
          days = d;
          days.forEach((ReplacementPlanDay day) => day.setColors());
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade),
        elevation: 0.0,
      ),
      body: Column(
          children: <Widget>[BrotherSisterReplacementPlanDayList(days: days)]),
    );
  }
}

class BrotherSisterReplacementPlanDayList extends StatefulWidget {
  final List<ReplacementPlanDay> days;

  BrotherSisterReplacementPlanDayList({Key key, this.days}) : super(key: key);

  @override
  BrotherSisterReplacementPlanDayListState createState() =>
      BrotherSisterReplacementPlanDayListState();
}

class BrotherSisterReplacementPlanDayListState
    extends State<BrotherSisterReplacementPlanDayList> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    super.initState();
  }

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
          // Tab bar header...
          appBar: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday), // Show all weekday names
              );
            }).toList(),
          ),
          // Tab bar views...
          body: TabBarView(
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(
                    right: 10.0, left: 10.0, bottom: 10.0, top: 0.0),
                // List of replacementplan information and all changes...
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    // For date information...
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

                    // Updated information...
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
                  ]..addAll(
                        // Show all changes in a list...
                        day.changes.map((change) {
                      return ReplacementPlanRow(
                          changes: day.changes, change: change);
                    }).toList()),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
