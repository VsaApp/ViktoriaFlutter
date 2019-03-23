import 'package:flutter/material.dart';

import '../../Rooms.dart';
import '../../Times.dart';
import '../UnitPlanModel.dart';

class UnitPlanRow extends StatelessWidget {
  final UnitPlanSubject subject;
  final int unit;
  final bool showUnit;
  final int weekday;
  final bool isDialog;

  UnitPlanRow({
    Key key,
    @required this.subject,
    @required this.unit,
    @required this.weekday,
    this.showUnit = true,
    this.isDialog = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width - (isDialog ? 168 : 40);
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Container(
            // Add padding if unit shown
            width: (showUnit) ? width * 0.1 : 0,
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
                width: width * 0.75,
                child: (unit != 5
                    ?
                // Normal name
                Text(
                  subject.lesson,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Theme
                        .of(context)
                        .primaryColor,
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
                width: width * 0.75,
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
                width: (showUnit) ? width * 0.15 : width * 0.25,
                child: Text(subject.teacher),
              ),
              // Room
              Container(
                // Add padding if unit not shown
                width: (showUnit) ? width * 0.15 : width * 0.25,
                child:
                Text(getRoom(weekday, unit, subject.lesson, subject.room)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
