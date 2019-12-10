import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Downloader/CalendarData.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Update.dart';

import 'CalendarGrid/CalendarGridWidget.dart';
import 'EventCard/EventCard.dart';

/// Calendar page with a event list and month grid view
class CalendarPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CalendarPage({Key key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

// ignore: public_member_api_docs
class CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  List<CalendarEvent> _events;
  static const _types = ['Liste', 'Monatsansicht'];
  TabController _tabController;

  /// Updates the calendar data
  Future update() async {
    final successfully = await CalendarData().download(context) == StatusCodes.success;
    dataUpdated(context, successfully, AppLocalizations.of(context).calendar);
    setState(setEvents);
  }

  /// Sort all events from today
  void setEvents() {
    List<CalendarEvent> events = Data.calendar.events;
    events = events.where((event) {
      return event.start.isAfter(DateTime.now()) ||
          event.end.isAfter(DateTime.now());
    }).toList();

    _events = events..sort((a, b) => a.start.isAfter(b.start) ? 1 : -1);
  }

  @override
  void initState() {
    setEvents();
    _tabController = TabController(vsync: this, length: _types.length);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _types.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        // Tab bar views
        appBar: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).accentColor,
          indicatorWeight: 2.5,
          tabs: _types.map((type) {
            return Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(type),
            );
          }).toList(),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _types.map((type) {
            final refreshIndicatorKey =
                GlobalKey<RefreshIndicatorState>();
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: update,
                key: refreshIndicatorKey,
                child: type == _types[0]
                    ? ListView(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        children: _events
                            .map((event) => EventCard(event: event))
                            .toList(),
                      )
                    : CalendarGrid(events: _events),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
