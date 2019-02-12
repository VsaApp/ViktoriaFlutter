import 'package:flutter/material.dart';
import '../ReplacementPlanModel.dart';

class ReplacementPlanRow extends StatelessWidget {
  const ReplacementPlanRow({Key key, this.change, this.changes})
      : super(key: key);

  final Change change;
  final List<dynamic> changes;

  @override
  Widget build(BuildContext context) {
    String nTeacher = change.teacher;
    //print(change.lesson + nTeacher);
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
                        (change.lesson.length > 0 ||
                                change.room.length > 0 ||
                                change.teacher.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.60,
                                child: Text(
                                  change.lesson,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Container(),
                        // Information
                        Container(
                            width: constraints.maxWidth * 0.60,
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
                            )),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // Original room
                        (change.lesson.length > 0 ||
                                change.room.length > 0 ||
                                change.teacher.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.15,
                                child: Text(
                                  change.room,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Container(),
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
                        (change.lesson.length > 0 ||
                                change.room.length > 0 ||
                                change.teacher.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.15,
                                child: Text(
                                  nTeacher,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Container(),
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
