import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Times.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

/// One unit in the timetable
class TimetableRow extends StatelessWidget {
  /// The selected subject
  final TimetableSubject subject;

  /// Defines if the unit should be shown
  final bool showUnit;

  /// Defines if the unit is shown in a dialog
  final bool isDialog;

  // ignore: public_member_api_docs
  const TimetableRow({
    @required this.subject,
    this.showUnit = true,
    this.isDialog = false,
    Key key,
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
                showUnit
                    ? (subject.unit != 5 && showUnit)
                        ? (subject.unit + 1).toString()
                        : ''
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
                        child: subject.unit != 5
                            ?
                            // Normal name
                            Text(
                                Data.subjects[
                                        subject.subjectID.toUpperCase()] ??
                                    subject.subjectID,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            :
                            // Lunch break
                            Center(
                                child: Text(
                                  Data.subjects[
                                          subject.subjectID.toUpperCase()] ??
                                      subject.subjectID,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          subject.teacherID.toUpperCase(),
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
                          subject.unit != 5 ? times[subject.unit] : '',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          subject.roomID,
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
