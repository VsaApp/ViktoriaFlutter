import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Rooms.dart';
import '../../Times.dart';
import '../UnitPlanModel.dart';

class UnitPlanRow extends StatelessWidget {
  final UnitPlanSubject subject;
  final int unit;
  final bool showUnit;
  final int weekday;
  final SharedPreferences sharedPreferences;

  UnitPlanRow({
    Key key,
    @required this.subject,
    @required this.unit,
    @required this.weekday,
    @required this.sharedPreferences,
    this.showUnit = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                // Add padding if unit shown
                width: (showUnit) ? constraints.maxWidth * 0.1 : 0,
                child: Text(
                  ((unit != 5 && showUnit) ? (unit + 1).toString() : ''),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  // Subject name
                  Container(
                    width: constraints.maxWidth * 0.75,
                    child: (unit != 5
                        ?
                        // Normal name
                        Text(
                            subject.lesson,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        :
                        // Lunch break
                        Center(
                            child: Text(
                              subject.lesson,
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          )),
                  ),
                  // Unit time
                  Container(
                    width: constraints.maxWidth * 0.75,
                    child: Text(
                      (unit != 5 ? times[unit] : ''),
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  // Teacher name
                  Container(
                    // Add padding if unit not shown
                    width: (showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(subject.teacher),
                  ),
                  // Room
                  Container(
                    // Add padding if unit not shown
                    width: (showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(getRoom(sharedPreferences, weekday, unit,
                        subject.lesson, subject.room)),
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
