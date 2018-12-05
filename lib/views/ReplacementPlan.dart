import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/ReplacementPlan.dart';
import '../models/ReplacementPlan.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../Keys.dart';

class ReplacementPlanPage extends StatefulWidget {
  @override
  ReplacementPlanView createState() => ReplacementPlanView();
}

class ReplacementPlanView extends State<ReplacementPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[ ReplacementPlanDayList(days: getReplacementPlan()) ]
    );
  }
}

class ReplacementPlanDayList extends StatefulWidget {
  final List<ReplacementPlanDay> days;

  ReplacementPlanDayList({Key key, this.days}) : super(key: key);

  @override
  ReplacementPlanDayListState createState() => ReplacementPlanDayListState();
}

class ReplacementPlanDayListState extends State<ReplacementPlanDayList> {
  
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
          appBar: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday),
              );
            }).toList(),
          ),
          body: TabBarView(
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0, top: 0.0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(text: 'Vertretungsplan für '),
                              new TextSpan(text: '${day.weekday}', style: new TextStyle(fontWeight: FontWeight.bold)),
                              new TextSpan(text: ', den '),
                              new TextSpan(text: '${day.date}', style: new TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(text: 'Zuletzt aktualisiert am '),
                              new TextSpan(text: '${day.update}', style: new TextStyle(fontWeight: FontWeight.bold)),
                              new TextSpan(text: ' um '),
                              new TextSpan(text: '${day.time}', style: new TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ),
                  ]..addAll((!sharedPreferences.getBool(Keys.sortReplacementPlan)) ? 
                    // Show all changes in a list...
                    day.changes.map((change) {
                      return ReplacementPlanRow(
                        changes: day.changes,
                        change: change
                      );
                    }).toList() : 

                    // Show the changes in three categories...
                    [
                      day.getMyChanges().length > 0 ?
                      Section(
                        title: AppLocalizations.of(context).myChanges,
                        children: day.getMyChanges().map((change) {
                          return ReplacementPlanRow(
                            changes: day.getMyChanges(),
                            change: change
                          );
                        }).toList()
                      ) : Container(),
                      day.getUndefChanges().length > 0 ?
                      Section(
                        title: AppLocalizations.of(context).undefChanges,
                        children: day.getUndefChanges().map((change) {
                          return ReplacementPlanRow(
                            changes: day.getUndefChanges(),
                            change: change
                          );
                        }).toList()
                      ) : Container (),
                      day.getOtherChanges().length > 0 ?
                      Section(
                        title: AppLocalizations.of(context).otherChanges,
                        children: day.getOtherChanges().map((change) {
                          return ReplacementPlanRow(
                            changes: day.getOtherChanges(),
                            change: change
                          );
                        }).toList()
                      ) : Container(),
                    ]
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

class Section extends StatefulWidget {
  final List<Widget> children;
  final String title;

  Section({Key key, this.children, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SectionView();
  }
}

class SectionView extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          widget.title, 
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            ),
          ),
          child: Column(
            children: widget.children,
          )
        )
        
      ],
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
      padding: EdgeInsets.only(top: showUnit ? (changes.indexOf(change) == 0 ? 10 : 20) : 5, bottom: 0, left: 10, right: 10),
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
                          left: BorderSide(width: 2, color: (change.color == null) ? Theme.of(context).primaryColor : change.color),
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
