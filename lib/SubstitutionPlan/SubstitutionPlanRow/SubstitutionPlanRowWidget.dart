import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

import 'package:viktoriaflutter/Utils/Rooms.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

class SubstitutionPlanRow extends StatelessWidget {
  const SubstitutionPlanRow({
    Key key,
    @required this.substitution,
    @required this.changes,
    @required this.weekday,
    this.isDialog = false,
    this.showUnit = true,
  }) : super(key: key);

  final Substitution substitution;
  final List<dynamic> changes;
  final int weekday;
  final bool isDialog;
  final bool showUnit;

  String getSubstitutionDescription(BuildContext context, int type) {
    switch (type) {
      case 0:
        return '';
      case 1:
        return AppLocalizations.of(context).freeLesson;
      case 2:
        return AppLocalizations.of(context).exam;
      default:
        return '';
    }
  }

  String getInfoText(BuildContext context, Substitution substitution) {
    String info = '';
    String description = getSubstitutionDescription(context, substitution.type);
    if (description.isNotEmpty) {
      info += description;
    } else if (substitution.changed.subjectID.isNotEmpty) {
      info += Data.subjects[substitution.changed.subjectID
                                  .toUpperCase()] ??
                              substitution.changed.subjectID;
    }
    if (substitution.info.isNotEmpty) {
      if (info.isNotEmpty) {
        info += ': ';
      }
      info += substitution.info;
    }
    return info;
  }

  @override
  Widget build(BuildContext context) {
    bool show = showUnit;
    if (changes.indexOf(substitution) != 0 &&
        changes[changes.indexOf(substitution) - 1].unit == substitution.unit) {
      show = false;
    }

    return Container(
      padding: EdgeInsets.only(
        // Add padding if unit not shown
        top: show ? (changes.indexOf(substitution) == 0 ? 10 : 20) : 5,
        right: 5,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Center(
              child: Text(
                (show) ? '${substitution.unit + 1}' : '',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 42,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      width: 2,
                      color: (substitution.color == null)
                          ?
                          // Default color
                          Theme.of(context).primaryColor
                          :
                          // Changed color
                          substitution.color),
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 60,
                        child: Text(
                          Data.subjects[substitution.original.subjectID
                                  .toUpperCase()] ??
                              substitution.original.subjectID,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          getRoom(
                            weekday,
                            substitution.unit,
                            substitution.original.subjectID,
                            substitution.original.roomID,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          substitution.original.teacherID.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
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
                          getInfoText(context, substitution),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          substitution.changed.roomID ==
                                  substitution.original.roomID
                              ? ''
                              : substitution.changed.roomID,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          substitution.original.teacherID ==
                                      substitution.changed.teacherID &&
                                  !substitution.isExam
                              ? ''
                              : substitution.changed.teacherID.toUpperCase(),
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
