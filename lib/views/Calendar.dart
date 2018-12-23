import 'package:flutter/material.dart';
import '../data/Calendar.dart';
import '../models/Calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  CalendarView createState() => CalendarView();
}

class CalendarView extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    List<CalendarEvent> events = getCalendar();
    events = events.where((event) {
      bool ok = true;
      DateTime d1 = DateTime(
          int.parse(event.start.date.split('.')[2]),
          int.parse(event.start.date.split('.')[1]),
          int.parse(event.start.date.split('.')[0]));
      ok = d1.isAfter(DateTime.now());
      if (event.end.date != '' && event.end.date != null) {
        DateTime d2 = DateTime(
            int.parse(event.end.date.split('.')[2]),
            int.parse(event.end.date.split('.')[1]),
            int.parse(event.end.date.split('.')[0]));
        if (!ok) {
          ok = d2.isAfter(DateTime.now());
        }
      }
      return ok;
    }).toList();
    events.sort((a, b) {
      DateTime d1 = DateTime(
          int.parse(a.start.date.split('.')[2]),
          int.parse(a.start.date.split('.')[1]),
          int.parse(a.start.date.split('.')[0]));
      DateTime d2 = DateTime(
          int.parse(b.start.date.split('.')[2]),
          int.parse(b.start.date.split('.')[1]),
          int.parse(b.start.date.split('.')[0]));
      print(d1.toString());
      print(d2.toString());
      print('');
      return d1.isAfter(d2) ? 1 : -1;
    });
    return Column(children: <Widget>[CalendarDayList(events: events)]);
  }
}

class CalendarDayList extends StatefulWidget {
  final List<CalendarEvent> events;

  CalendarDayList({Key key, this.events}) : super(key: key);

  @override
  CalendarDayListState createState() => CalendarDayListState();
}

class CalendarDayListState extends State<CalendarDayList> {
  @override
  void initState() {
    super.initState();
  }

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
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text(event.info != '' ? event.info : '-'),
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
                              : Text('-')
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
