import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

class EventCard extends StatelessWidget {
  EventCard({@required this.event}) : super();
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    String startDate = event.start != null
        ? event.start.day.toString() +
            '.' +
            event.start.month.toString() +
            '.' +
            event.start.year.toString()
        : '';
    String startTime = event.start != null
        ? (event.start.hour.toString().length == 1 ? '0' : '') +
            event.start.hour.toString() +
            ':' +
            (event.start.minute.toString().length == 1 ? '0' : '') +
            event.start.minute.toString()
        : '';
    String endDate = event.end != null
        ? event.end.day.toString() +
            '.' +
            event.end.month.toString() +
            '.' +
            event.end.year.toString()
        : '';
    String endTime = event.end != null
        ? (event.end.hour.toString().length == 1 ? '0' : '') +
            event.end.hour.toString() +
            ':' +
            (event.end.minute.toString().length == 1 ? '0' : '') +
            event.end.minute.toString()
        : '';
    String line1 = startDate;
    String line2 = 'bis $endDate';
    if (startDate != endDate) {
      line1 += startTime != '00:00' ? ' ($startTime Uhr)' : '';
      line2 += endTime != '00:00' ? ' ($endTime Uhr)' : '';
    } else {
      if (startTime != endTime) {
        line2 = '$startTime - $endTime Uhr';
      } else if (startTime != '00:00') {
        line2 = '$startTime Uhr';
      } else {
        line2 = '';
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Add2Calendar.addEvent2Cal(Event(
                  title: event.name,
                  description: event.info,
                  startDate: event.start,
                  endDate: event.end,
                ));
              },
              child: ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).accentColor),
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
                      Text(line1),
                      if (line2.isNotEmpty) Text(line2)
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
