import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

import '../Localizations.dart';
import '../data/Calendar.dart';
import '../models/Calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  CalendarView createState() => CalendarView();
}

class CalendarView extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[CalendarDayList(events: getCalendar())]);
  }
}

class CalendarDayList extends StatefulWidget {
  final List<CalendarEvent> events;

  CalendarDayList({Key key, this.events}) : super(key: key);

  @override
  CalendarDayListState createState() => CalendarDayListState();
}

class CalendarDayListState extends State<CalendarDayList> {
  EventList _markedDateMap = EventList(events: {});
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    // Map events
    widget.events.forEach((event) {
      if (event.start.date != event.end.date && event.end.date != null) {
        // Event is longer than one day
        final start = DateTime(
            int.parse(event.start.date.split('.')[2]),
            int.parse(event.start.date.split('.')[1]),
            int.parse(event.start.date.split('.')[0]));
        final end = DateTime(
            int.parse(event.end.date.split('.')[2]),
            int.parse(event.end.date.split('.')[1]),
            int.parse(event.end.date.split('.')[0]));
        for (int i = 0; i < end.difference(start).inDays + 1; i++) {
          // Added event for every day
          var date = start;
          date = date.add(Duration(days: i));
          addEvent(CalendarEvent(
              name: event.name,
              info: event.info,
              start: CalendarEventDate(
                  date: date.day.toString() +
                      '.' +
                      date.month.toString() +
                      '.' +
                      date.year.toString(),
                  time: event.start.time),
              end: event.end));
        }
      } else {
        // Event is only on one day
        addEvent(event);
      }
    });
    super.initState();
  }

  // Add an event to the list of the marked events
  void addEvent(CalendarEvent event) {
    _markedDateMap.add(
      DateTime(
          int.parse(event.start.date.split('.')[2]),
          int.parse(event.start.date.split('.')[1]),
          int.parse(event.start.date.split('.')[0])),
      Event(
        date: DateTime(
            int.parse(event.start.date.split('.')[2]),
            int.parse(event.start.date.split('.')[1]),
            int.parse(event.start.date.split('.')[0])),
        title: event.name +
            (event.info != '' ? ' - ${event.info}' : '') +
            (event.start.time != ''
                ? ' (${event.start.time} - ${event.end.time} Uhr)'
                : ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel(
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate = date);
        if (events.length > 0) {
          // Show information about the events on the clicked date
          showDialog<String>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context1) {
                return SimpleDialog(
                    title: Text(AppLocalizations.of(context).dates +
                        ' - ' +
                        events[0].date.day.toString() +
                        '.' +
                        events[0].date.month.toString() +
                        '.' +
                        events[0].date.year.toString()),
                    // List of event names
                    children: events.map((event) {
                      return SimpleDialogOption(
                        child: Text(event.title),
                      );
                    }).toList());
              });
        }
      },
      selectedDateTime: _currentDate,
      markedDatesMap: _markedDateMap,
      weekendTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      todayButtonColor: Theme.of(context).primaryColor,
      todayBorderColor: Theme.of(context).primaryColor,
      thisMonthDayBorderColor: Theme.of(context).accentColor,
      markedDateWidget: Container(
        child: Text(
          '.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 25.0,
          ),
        ),
      ),
      weekdayTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
      //weekDays: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
      weekFormat: false,
      height: 420.0,
      daysHaveCircularBorder: false,
    );
  }
}
