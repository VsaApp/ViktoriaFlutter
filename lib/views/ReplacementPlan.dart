import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './BrotherSisterReplacementPlan.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../data/ReplacementPlan.dart';
import '../models/ReplacementPlan.dart';
import '../models/UnitPlan.dart';

class ReplacementPlanPage extends StatefulWidget {
  @override
  ReplacementPlanView createState() => ReplacementPlanView();
}

class ReplacementPlanView extends State<ReplacementPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[ReplacementPlanDayList(days: getReplacementPlan())]);
  }
}

class ReplacementPlanDayList extends StatefulWidget {
  final List<ReplacementPlanDay> days;

  ReplacementPlanDayList({Key key, this.days}) : super(key: key);

  @override
  ReplacementPlanDayListState createState() => ReplacementPlanDayListState();
}

class ReplacementPlanDayListState extends State<ReplacementPlanDayList>
    with SingleTickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  TabController _tabController;
  static List<String> _grades = [
    '5a',
    '5b',
    '5c',
    '6a',
    '6b',
    '6c',
    '7a',
    '7b',
    '7c',
    '8a',
    '8b',
    '8c',
    '9a',
    '9b',
    '9c',
    'EF',
    'Q1',
    'Q2'
  ];

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
      });
    });
    _tabController = new TabController(vsync: this, length: widget.days.length);
    int day = 0;
    if (widget.days.length > 1) {
      bool over = false;
      int weekday = DateTime.now().weekday;
      if (weekday <= 4) {
        if (UnitPlan.days[weekday].lessons.length > 0) {
          if (DateTime.now().isAfter(DateTime(DateTime
              .now()
              .year,
              DateTime
                  .now()
                  .month, DateTime
                  .now()
                  .day, 8)
              .add(Duration(
              minutes: [
            60,
            130,
            210,
            280,
            360,
            420,
            480,
            545
          ][UnitPlan.days[weekday].lessons.length - 1])))) {
            over = true;
          }
        }
      }

      // If the first day is passed, select the next day...
      if (DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).add(Duration(days: (over) ? 1 : 0)).isAfter(DateTime(
        (int.parse(widget.days[0].date.split('.')[2]) < 2000)
            ? (int.parse(widget.days[0].date.split('.')[2]) + 2000)
            : (int.parse(widget.days[0].date.split('.')[2])),
        int.parse(widget.days[0].date.split('.')[1]),
        int.parse(widget.days[0].date.split('.')[0]),
      ))) day = 1;

      _tabController.animateTo(day);
    }

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
            controller: _tabController,
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
            controller: _tabController,
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      margin:
                      EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(AppLocalizations.of(context)
                              .showReplacementPlanForBrotherSister),
                          onPressed: () {
                            showDialog<String>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context1) {
                                  return SimpleDialog(
                                    title: Text(AppLocalizations.of(context)
                                        .pleaseSelect),
                                    children: _grades.map((_grade) {
                                      return SimpleDialogOption(
                                        onPressed: () {
                                          print(_grade);
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BrotherSisterReplacementPlanPage(
                                                          grade: _grade)));
                                        },
                                        child: Text(_grade),
                                      );
                                    }).toList(),
                                  );
                                });
                          },
                        ),
                      ),
                    ),
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
                              children: day.getMyChanges().length > 0
                                  ? day.getMyChanges().map((change) {
                                      return ReplacementPlanRow(
                                          changes: day.getMyChanges(),
                                          change: change);
                                    }).toList()
                                  : <Widget>[
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
                                    ]),
                          day.getUndefChanges().length > 0
                              ? Section(
                                  title:
                                      AppLocalizations.of(context).undefChanges,
                                  children: day.getUndefChanges().map((change) {
                                    return ReplacementPlanRow(
                                        changes: day.getUndefChanges(),
                                        change: change);
                                  }).toList())
                              : Container(),
                          day.getOtherChanges().length > 0
                              ? Section(
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
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Container(
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
              ))
        ],
      ),
    );
  }
}

class ReplacementPlanRow extends StatelessWidget {
  const ReplacementPlanRow({Key key, this.change, this.changes})
      : super(key: key);

  final Change change;
  final List<dynamic> changes;

  @override
  Widget build(BuildContext context) {
    String nTeacher = change.teacher;
    String cTeacher = change.changed.teacher;
    bool showUnit = true;
    if (changes.indexOf(change) !=
        0) if (changes[changes.indexOf(change) - 1].unit == change.unit)
      showUnit = false;
    return Container(
      padding: EdgeInsets.only(
          top: showUnit ? (changes.indexOf(change) == 0 ? 10 : 20) : 5,
          bottom: 0,
          left: 10,
          right: 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Column(children: <Widget>[
                Container(
                  width: constraints.maxWidth * 0.07,
                  child: Text(
                    (showUnit) ? '${change.unit + 1}' : '',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ]),
              Container(
                padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.03 - 2, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        width: 2,
                        color: (change.color == null)
                            ? Theme.of(context).primaryColor
                            : change.color),
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
                            )),
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
                            change.changed.room == change.room
                                ? ''
                                : change.changed.room,
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
                              nTeacher == cTeacher &&
                                      change.changed.info != 'Klausur'
                                  ? ''
                                  : cTeacher,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )),
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
