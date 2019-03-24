import 'package:flutter/material.dart';

import '../../Rooms.dart';
import '../ReplacementPlanModel.dart';

class ReplacementPlanRow extends StatelessWidget {
  const ReplacementPlanRow({
    Key key,
    @required this.change,
    @required this.changes,
    @required this.weekday,
    this.isDialog = false,
    this.showUnit = true,
  }) : super(key: key);

  final Change change;
  final List<dynamic> changes;
  final int weekday;
  final bool isDialog;
  final bool showUnit;

  @override
  Widget build(BuildContext context) {
    bool show = showUnit;
    if (changes.indexOf(change) != 0 &&
        changes[changes.indexOf(change) - 1].unit == change.unit) {
      show = false;
    }
    return Container(
      margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Center(
              child: Text(
                (show) ? '${change.unit + 1}' : '',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 35,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2,
                    color: (change.color == null)
                        ? Theme
                        .of(context)
                        .primaryColor
                        : change.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 90,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 60,
                        child: Text(
                          change.lesson,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          getRoom(
                            weekday,
                            change.unit,
                            change.lesson,
                            change.room,
                          ),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          change.teacher,
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 60,
                        child: Text(
                          (change.changed.subject != ''
                              ? change.changed.subject
                              : '') +
                              (change.changed.info != '' &&
                                  change.changed.subject != ''
                                  ? ': '
                                  : '') +
                              (change.changed.info != ''
                                  ? change.changed.info
                                  : ''),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          change.changed.room == change.room
                              ? ''
                              : change.changed.room,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          change.teacher == change.changed.teacher &&
                              change.changed.info != 'Klausur'
                              ? ''
                              : change.changed.teacher,
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
