import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Downloader/CalendarData.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'CalendarGrid/CalendarGridWidget.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'EventCard/EventCard.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Update.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  List<CalendarEvent> events;
  List<String> types = ['Liste', 'Monatsansicht'];
  TabController tabController;

  Future update() async {
    bool successfully = await CalendarData().download(context) == StatusCodes.success;
    dataUpdated(context, successfully, AppLocalizations.of(context).calendar);
    setState(() => setEvents());
  }

  void setEvents() {
    List<CalendarEvent> events = Data.calendar.events;
    events = events.where((event) {
      return event.start.isAfter(DateTime.now()) ||
          event.end.isAfter(DateTime.now());
    }).toList();

    events.sort((a, b) => a.start.isAfter(b.start) ? 1 : -1);
    this.events = events;
  }

  @override
  void initState() {
    setEvents();
    tabController = TabController(vsync: this, length: types.length);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: types.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        // Tab bar views
        appBar: TabBar(
          controller: tabController,
          indicatorColor: Theme.of(context).accentColor,
          indicatorWeight: 2.5,
          tabs: types.map((type) {
            return Container(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: Text(type),
            );
          }).toList(),
        ),
        body: TabBarView(
          controller: tabController,
          children: types.map((type) {
            GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
                GlobalKey<RefreshIndicatorState>();
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: update,
                key: refreshIndicatorKey,
                child: type == types[0]
                    ? ListView(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        children: events
                            .map((event) => EventCard(event: event))
                            .toList(),
                      )
                    : CalendarGrid(events: events),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
