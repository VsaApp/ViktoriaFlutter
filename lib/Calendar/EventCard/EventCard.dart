import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../CalendarModel.dart';

class EventCard extends StatelessWidget {
  EventCard({@required this.event}) : super();
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                DateFormat format = DateFormat('dd.MM.yyyy HH:mm');
                Add2Calendar.addEvent2Cal(Event(
                  title: event.name,
                  description: event.info,
                  startDate: format.parse(event.start.date +
                      ' ' +
                      (event.start.time != '' ? event.start.time : '00:00')),
                  endDate: format.parse(event.end.date +
                      ' ' +
                      (event.end.time != '' ? event.end.time : '23:59')),
                ));
              },
              child: ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme
                        .of(context)
                        .accentColor),
                title: Text(event.name),
                subtitle: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child:
                        event.info != '' ? Text(event.info) : Container(),
                      ),
                      Text((event.start.date) +
                          (event.start.time != ''
                              ? ' (' + (event.start.time) + ' Uhr)'
                              : '')),
                      (event.start.date) + (event.start.time) !=
                          (event.end.date ?? '') + (event.end.time ?? '')
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
            ),
          ],
        ),
      ),
    );
  }
}
