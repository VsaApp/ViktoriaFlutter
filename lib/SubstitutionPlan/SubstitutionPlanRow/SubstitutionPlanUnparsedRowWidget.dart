import 'package:flutter/material.dart';

import '../SubstitutionPlanModel.dart';

class SubstitutionPlanUnparsedRow extends StatelessWidget {
  const SubstitutionPlanUnparsedRow({Key key, this.change, this.changes})
      : super(key: key);

  final Change change;
  final List<dynamic> changes;

  @override
  Widget build(BuildContext context) {
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
                  border:
                      Border(left: BorderSide(width: 2, color: Colors.blue)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Original subject
                        (change.original.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.60,
                                child: Text(
                                  change.original[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Container()
                      ]..addAll(change.original.sublist(1).map((line) {
                          return Container(
                              width: constraints.maxWidth * 0.60,
                              child: Text(
                                line.toString(),
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ));
                        }).toList()),
                    ),
                    Column(
                        children: <Widget>[
                      // Original subject
                      (change.change.length > 0)
                          ? Container(
                              width: constraints.maxWidth * 0.40,
                              child: Text(
                                change.change[0],
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Container()
                    ]..addAll(change.change.sublist(1).map((line) {
                            return Container(
                                width: constraints.maxWidth * 0.40,
                                child: Text(
                                  line.toString(),
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ));
                          }).toList())),
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
