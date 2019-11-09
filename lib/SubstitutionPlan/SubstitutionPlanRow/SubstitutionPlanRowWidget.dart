import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Rooms.dart';
import '../SubstitutionPlanModel.dart';

class SubstitutionPlanRow extends StatelessWidget {
  const SubstitutionPlanRow({
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
      padding: EdgeInsets.only(
        // Add padding if unit not shown
        top: show ? (changes.indexOf(change) == 0 ? 10 : 20) : 5,
        right: 5,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Center(
              child: Text(
                (show) ? '${change.unit + 1}' : '',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: !change.isRewriteExam ? 42 : 24,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      width: 2,
                      color: (change.color == null)
                          ?
                      // Default color
                      Theme
                          .of(context)
                          .primaryColor
                          :
                      // Changed color
                      change.color),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 92,
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
              child: Column(
                children: <Widget>[
                  !change.isRewriteExam ?
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
                  ) : Container(),
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
                            color: Colors.black54,
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
