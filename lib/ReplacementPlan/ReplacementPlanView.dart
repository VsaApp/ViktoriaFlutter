import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Color.dart';
import '../BrotherSisterReplacementPlan/BrotherSisterReplacementPlanView.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Subjects.dart';
import '../ReplacementPlan/ReplacementPlanData.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanModel.dart';

class ReplacementPlanPage extends StatefulWidget {
  @override
  ReplacementPlanView createState() => ReplacementPlanView();
}

class ReplacementPlanView extends State<ReplacementPlanPage> {
  SharedPreferences sharedPreferences;
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ReplacementPlanDay> data = getReplacementPlan();
    return new Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[ReplacementPlanDayList(days: data)],
        ),
        // FAB
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Container(
              child: GradeFab(
                onSelectPressed: (Function(String grade) selected) {
                  // Select a grade to show the replacement plan of
                  showDialog<String>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context1) {
                        return SimpleDialog(
                          title:
                              Text(AppLocalizations.of(context).pleaseSelect),
                          children: _grades.map((_grade) {
                            return SimpleDialogOption(
                              onPressed: () {
                                print(_grade);
                                selected(_grade);
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
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
                onSelected: (String grade) {
                  // Show replacement plan for another grade
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          BrotherSisterReplacementPlanPage(grade: grade)));
                },
              ),
            )),
      ]),
    );
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
    // Select the correct tab
    _tabController = new TabController(vsync: this, length: widget.days.length);
    int day = 0;
    if (widget.days.length > 1) {
      bool over = false;
      int weekday = DateTime.now().weekday;
      if (weekday <= 4) {
        if (UnitPlan.days[weekday].lessons.length > 0) {
          if (DateTime.now().isAfter(DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day, 8)
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
          // Tab bar views
          body: TabBarView(
            controller: _tabController,
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

class Section extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final bool isLast;

  Section({Key key, this.children, this.title, this.isLast = false})
      : super(key: key);

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
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(widget.title),
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
                // List of items
                child: Column(
                  children: widget.children,
                )),
          ],
        ),
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
          // Add padding if unit not shown
          top: showUnit ? (changes.indexOf(change) == 0 ? 10 : 20) : 5,
          // Add padding if row is last row
          bottom: 0,
          left: 10,
          right: 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Column(children: <Widget>[
                // Show unit of change
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
                            ?
                            // Default color
                            Theme.of(context).primaryColor
                            :
                            // Changed color
                            change.color),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Original subject
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
                        // Information
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
                        // Original room
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            change.room,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Changed room
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
                        // Original teacher
                        Container(
                          width: constraints.maxWidth * 0.15,
                          child: Text(
                            nTeacher,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // Changed teacher
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

class GradeFab extends StatefulWidget {
  final Function(Function(String grade)) onSelectPressed;
  final Function(String grade) onSelected;

  GradeFab({this.onSelectPressed, this.onSelected});

  @override
  _GradeFabState createState() => _GradeFabState();
}

class _GradeFabState extends State<GradeFab>
    with SingleTickerProviderStateMixin {
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

  SharedPreferences sharedPreferences;
  bool isOpened = false;
  List<String> grades;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 50.0;
  String grade;

  @override
  initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        grade = instance.getString(Keys.grade);
        grades = (instance.getString(Keys.lastGrades) ?? '').split(':');
        if (grades.length > 0) if (grades[0].length == 0) grades = [];
      });
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // Create animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _buttonColor = ColorTween(
          begin: Theme.of(context).primaryColor,
          end: getColorHexFromStr('#275600'),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.00,
            1.00,
            curve: Curves.linear,
          ),
        ));
        _translateButton = Tween<double>(
          begin: _fabHeight,
          end: 0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.75,
            curve: _curve,
          ),
        ));
      });
    });
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  // Update last selected grades
  void updatePrefs(String grade) {
    if (!grades.contains(grade)) {
      setState(() {
        if (grades.length == 0) {
          sharedPreferences.setString(Keys.lastGrades, grade);
          grades.add(grade);
        } else if (grades.length == 1) {
          sharedPreferences.setString(Keys.lastGrades, grades[0] + ':' + grade);
          grades.add(grade);
        } else {
          sharedPreferences.setString(Keys.lastGrades, grades[1] + ':' + grade);
          grades[0] = grades[1];
          grades[1] = grade;
        }
      });
    }
  }

  // Smaller select FAB
  Widget select() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'select',
        mini: true,
        onPressed: () {
          animate();
          widget.onSelectPressed(updatePrefs);
        },
        tooltip: 'Select',
        child: Icon(Icons.playlist_add, color: Colors.white),
      ),
    );
  }

  // Toggle FAB
  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'main',
        backgroundColor: _buttonColor.value,
        onPressed: () {
          if (grades.length > 0)
            animate();
          else
            widget.onSelectPressed(updatePrefs);
        },
        tooltip: 'Grade',
        child: AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null ||
        _translateButton == null ||
        _buttonColor == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * (grades.length + 1),
            0.0,
          ),
          child: select(),
        ),
        toggle(),
      ]..insertAll(
          1,
          grades.map((grade) {
            return Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  _translateButton.value *
                      (grades.length - grades.indexOf(grade)),
                  0.0,
                ),
                child: Container(
                  // Create FAB for every grade
                  child: FloatingActionButton(
                    heroTag: 'grade' + grade,
                    mini: true,
                    onPressed: () {
                      animate();
                      List<String> prefValue =
                          (sharedPreferences.getString(Keys.lastGrades) ?? '')
                              .split(':');
                      if (prefValue.length > 0) if (prefValue[0].length == 0)
                        prefValue = [];
                      if (!prefValue.contains(grade)) {
                        setState(() {
                          if (prefValue.length == 0) {
                            sharedPreferences.setString(Keys.lastGrades, grade);
                            grades[1] = grade;
                          } else if (prefValue.length == 1) {
                            sharedPreferences.setString(
                                Keys.lastGrades, prefValue[0] + ':' + grade);
                            grades[1] = grade;
                          } else {
                            sharedPreferences.setString(
                                Keys.lastGrades, prefValue[1] + ':' + grade);
                            grades[0] = grades[1];
                            grades[1] = grade;
                          }
                        });
                      }
                      widget.onSelected(grade);
                    },
                    tooltip: grade,
                    child: Text(grade, style: TextStyle(color: Colors.white)),
                  ),
                ));
          }).toList(),
        ),
    );
  }
}
