import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Models/Models.dart';

/// A row for one subject (for substitution or timetable)
abstract class SubjectRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubjectRow({
    @required this.details,
    @required this.index,
    this.showUnit = true,
    this.topicColor,
    this.coloredInfos = true,
    this.hideUnit = false,
    Key key,
  }) : super(key: key);

  /// The color of the vertical line
  final Color topicColor;

  /// The index details for the row
  final int index;

  /// Defines if the infos should be colored
  final bool coloredInfos;

  /// All details in this unit
  ///
  /// To show if the row should has an unit number or not
  final List<SubjectRowDetails> details;

  /// If the unit should be shown
  final bool showUnit;

  /// Hides the complete space for the unit
  final bool hideUnit;

  @override
  Widget build(BuildContext context) {
    final SubjectRowDetails _rowDetails = details[index];
    bool show = showUnit;
    if (index != 0 && details[index - 1].unit == _rowDetails.unit) {
      show = false;
    }

    return Container(
      padding: EdgeInsets.only(
          // Add padding if unit not shown
          top: show ? 10 : 3,
          right: 3,
          left: 3),
      child: Row(
        children: <Widget>[
          if (!hideUnit)
            Expanded(
              flex: 7,
              child: Center(
                child: Text(
                  show ? '${_rowDetails.unit + 1}' : '',
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
                  color: topicColor ?? Colors.transparent,
                )),
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
                          _rowDetails.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          _rowDetails.infoLeftTop ?? '',
                          style: TextStyle(
                            color: coloredInfos
                                ? Theme.of(context).primaryColor
                                : Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          _rowDetails.infoRightTop ?? '',
                          style: TextStyle(
                              color: coloredInfos
                                  ? Theme.of(context).primaryColor
                                  : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 60,
                        child: Text(
                          _rowDetails.subtitle ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          _rowDetails.infoLeftBottom ?? '',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 20,
                        child: Text(
                          _rowDetails.infoRightBottom ?? '',
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
