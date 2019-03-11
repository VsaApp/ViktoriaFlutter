import 'package:flutter/material.dart';

import '../CalendarData.dart';
import '../CalendarModel.dart';

class CalendarDayList extends StatefulWidget {
  CalendarDayList({Key key}) : super(key: key);

  @override
  CalendarDayListState createState() => CalendarDayListState();
}

class CalendarDayListState extends State<CalendarDayList> {
  List<CalendarEvent> events;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future update() async {
    await download();
    setState(() => setEvents());
  }

  void setEvents() {
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
      return d1.isAfter(d2) ? 1 : -1;
    });

    this.events = events;
  }

  @override
  void initState() {
    setEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: update,
        key: refreshIndicatorKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          children: events.map((event) {
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
                              child: event.info != ''
                                  ? Text(event.info)
                                  : Container(),
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
      ),
    );
  }
}
