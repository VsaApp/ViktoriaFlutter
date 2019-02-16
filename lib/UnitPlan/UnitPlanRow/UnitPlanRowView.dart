import 'package:flutter/material.dart';

import '../../Rooms.dart';
import '../../Times.dart';
import 'UnitPlanRowWidget.dart';

class UnitPlanRowView extends UnitPlanRowState {
  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                // Add padding if unit shown
                width: (widget.showUnit) ? constraints.maxWidth * 0.1 : 0,
                child: Text(
                  ((widget.unit != 5 && widget.showUnit)
                      ? (widget.unit + 1).toString()
                      : ''),
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
                    child: (widget.unit != 5
                        ?
                        // Normal name
                        Text(
                            widget.subject.lesson,
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
                              widget.subject.lesson,
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
                      (widget.unit != 5 ? times[widget.unit] : ''),
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
                    width: (widget.showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(widget.subject.teacher),
                  ),
                  // Room
                  Container(
                    // Add padding if unit not shown
                    width: (widget.showUnit)
                        ? constraints.maxWidth * 0.15
                        : constraints.maxWidth * 0.25,
                    child: Text(getRoom(
                        sharedPreferences,
                        widget.weekday,
                        widget.unit,
                        widget.subject.lesson,
                        widget.subject.room)),
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
