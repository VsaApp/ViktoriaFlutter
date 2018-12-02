import 'package:flutter/material.dart';
import '../data/ReplacementPlan.dart';
import '../models/ReplacementPlan.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../Color.dart';

class ReplacementPlanPage extends StatefulWidget {
  @override
  ReplacementPlanView createState() => ReplacementPlanView();
}

class ReplacementPlanView extends State<ReplacementPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder<List<ReplacementPlanDay>>(
          future: fetchDays(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ReplacementPlanDayList(days: snapshot.data)
                : Container();
          },
        )
      ],
    );
  }
}

class ReplacementPlanDayList extends StatelessWidget {
  final List<ReplacementPlanDay> days;

  ReplacementPlanDayList({Key key, this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday),
              );
            }).toList(),
          ),
          body: TabBarView(
            children: days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: ListView(
                  shrinkWrap: true,
                  children: day.changes.map((change) {
                    return ReplacementPlanRow(
                      changes: day.changes,
                      change: change
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class ReplacementPlanRow extends StatelessWidget {
  const ReplacementPlanRow({
    Key key,
    this.change,
    this.changes
  }) : super(key: key);

  final Change change;
  final List<dynamic> changes;

  @override
  Widget build(BuildContext context) {
    String nTeacher = change.teacher.replaceAll('Ã', 'Ö');
    if (nTeacher.length > 0) {
      nTeacher = nTeacher.substring(0, 2) + nTeacher.split('')[nTeacher.length - 1];
    }
    String cTeacher = change.changed.teacher.replaceAll('Ã', 'Ö');
    if (cTeacher.length > 0) {
      cTeacher = cTeacher.substring(0, 2) + cTeacher.split('')[cTeacher.length - 1];
    }
    bool showUnit = true;
    if (changes.indexOf(change) != 0) if (changes[changes.indexOf(change) - 1].unit == change.unit) showUnit = false;
    return Container(
      padding: EdgeInsets.only(top: showUnit ? 20 : 5, bottom: 0, left: 10, right: 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: constraints.maxWidth * 0.07,
                    child: Text(
                      (showUnit) ? '${change.unit}' : '',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ]
              ),
              Container(
                padding: EdgeInsets.only(left: constraints.maxWidth * 0.03 - 2, top: 5, bottom: 5),
                decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                      ),
                ),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: constraints.maxWidth * 0.60,
                          child: Text(
                              getSubject(change.lesson),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Theme.of(context).primaryColor,
                              ),
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth * 0.60,
                          child: Text(
                            change.changed.info,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            change.room,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            change.changed.room == change.room ? '' : change.changed.room,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            nTeacher,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            nTeacher == cTeacher && change.changed.info != 'Klausur' ? '' : cTeacher,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
