import 'package:flutter/material.dart';

import '../data/WorkGroups.dart';
import '../models/WorkGroups.dart';

class WorkGroupsPage extends StatefulWidget {
  @override
  WorkGroupsView createState() => WorkGroupsView();
}

class WorkGroupsView extends State<WorkGroupsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[WorkGroupsDayList(days: getWorkGroups())]);
  }
}

class WorkGroupsDayList extends StatefulWidget {
  final List<WorkGroupsDay> days;

  WorkGroupsDayList({Key key, this.days}) : super(key: key);

  @override
  WorkGroupsDayListState createState() => WorkGroupsDayListState();
}

class WorkGroupsDayListState extends State<WorkGroupsDayList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: widget.days.length);
    int weekday = DateTime.now().weekday - 1;
    if (weekday > 4) {
      weekday = 0;
    }
    _tabController.animateTo(weekday);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday.substring(0, 2).toUpperCase()),
              );
            }).toList(),
          ),
          body: TabBarView(
            controller: _tabController,
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  children: day.data.map((workgroup) {
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    width: constraints.maxWidth * 0.75,
                                    child: Text(
                                      workgroup.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: constraints.maxWidth * 0.75,
                                    child: Text(
                                      workgroup.time,
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text(
                                      workgroup.participants,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Container(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text(
                                      workgroup.place,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
