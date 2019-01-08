import 'package:flutter/material.dart';
import '../CalendarModel.dart';

class CalendarDayList extends StatefulWidget {
  final List<CalendarEvent> events;

  CalendarDayList({Key key, this.events}) : super(key: key);

  @override
  CalendarDayListState createState() => CalendarDayListState();
}

class CalendarDayListState extends State<CalendarDayList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        children: widget.events.map((event) {
          return Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.calendar_today,
                        color: Theme.of(context).accentColor),
                    title: Text(event.name),
                    subtitle: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: event.info != '' ? Text(event.info) : Container(),
                          ),
                          Text((event.start.date) +
                              (event.start.time != ''
                                  ? ' (' + (event.start.time) + ' Uhr)'
                                  : '')),
                          (event.start.date) + (event.start.time) !=
                                  (event.end.date ?? '') +
                                      (event.end.time ?? '')
                              ? Text('bis ' +
                                  (event.end.date) +
                                  (event.end.time != ''
                                      ? ' (' + (event.end.time) + ' Uhr)'
                                      : ''))
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
