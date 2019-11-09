import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Rooms.dart';
import 'package:viktoriaflutter/Utils/Times.dart';
import '../TimetableModel.dart';

class TimetableRow extends StatelessWidget {
  final TimetableSubject subject;
  final int unit;
  final bool showUnit;
  final int weekday;
  final bool isDialog;

  TimetableRow({
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
      padding: EdgeInsets.only(top: 10, left: 3, right: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: showUnit ? 8 : 0,
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
            flex: showUnit ? 92 : 100,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5, left: 2.5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 76,
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
                        flex: 20,
                        child: Text(
                          subject.teacher,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 76,
                        child: Text(
                          (unit != 5 ? times[unit] : ''),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          getRoom(weekday, unit, subject.lesson, subject.room),
                          style: TextStyle(
                            color: Colors.black54,
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
