import 'package:flutter/material.dart';
import '../data/UnitPlan.dart';
import '../models/UnitPlan.dart';
import '../Times.dart';
import '../Localizations.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder<List<UnitPlanDay>>(
          future: fetchDays(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? UnitPlanDayList(days: snapshot.data)
                : Container();
          },
        )
      ],
    );
  }
}

class UnitPlanDayList extends StatelessWidget {
  final List<UnitPlanDay> days;

  UnitPlanDayList({Key key, this.days}) : super(key: key);

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
                child: Text(day.name.substring(0, 2).toUpperCase()),
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
                  children: day.lessons.map((lesson) {
                    if (lesson.subjects.length > 0) {
                      UnitPlanSubject subject =
                          lesson.subjects[lesson.selected];
                      return UnitPlaRow(
                        subject: subject,
                        unit: day.lessons.indexOf(lesson),
                      );
                    }
                    if (day.lessons.indexOf(lesson) == 5) {
                      return UnitPlaRow(
                        subject: UnitPlanSubject(
                            teacher: '',
                            lesson: AppLocalizations.of(context).lunchBreak,
                            room: '',
                            block: ''),
                        unit: day.lessons.indexOf(lesson),
                      );
                    }
                    return Container();
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

class UnitPlaRow extends StatelessWidget {
  const UnitPlaRow({
    Key key,
    this.subject,
    this.unit,
  }) : super(key: key);

  final UnitPlanSubject subject;
  final int unit;

  @override
  Widget build(BuildContext context) {
    String teacher = subject.teacher.replaceAll('Ã', 'Ö');
    if (teacher.length > 0) {
      teacher = teacher.substring(0, 2) + teacher.split('')[teacher.length - 1];
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                width: constraints.maxWidth / 10,
                child: Text(
                  (unit + 1).toString(),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: constraints.maxWidth / 10 * 8,
                    child: Text(
                      subject.lesson,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth / 10 * 8,
                    child: Text(
                      times[unit],
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
                    width: constraints.maxWidth / 10,
                    child: Text(teacher),
                  ),
                  Container(
                    width: constraints.maxWidth / 10,
                    child: Text(subject.room),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
