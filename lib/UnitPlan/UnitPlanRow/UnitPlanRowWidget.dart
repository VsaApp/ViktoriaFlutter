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
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: showUnit ? 10 : 0,
            child: Center(
              child: Text(
                (showUnit)
                    ? '${((unit != 5 && showUnit)
                    ? (unit + 1).toString()
                    : '')}'
                    : '',                  
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
          ),
          Expanded(
            flex: showUnit ? 90 : 100,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5, left: 2.5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 84,
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
                      Expanded(
                        flex: 16,
                        child: Text(
                          subject.teacher,
                          style: TextStyle(
                            color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                        flex: 84,
                        child: Text(
                          (unit != 5 ? times[unit] : ''),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 16,
                        child: Text(
                          getRoom(weekday, unit, subject.lesson, subject.room),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
