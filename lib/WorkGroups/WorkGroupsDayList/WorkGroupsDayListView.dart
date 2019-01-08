import 'package:flutter/material.dart';
import 'WorkGroupsDayListWidget.dart';

class WorkGroupsDayListView extends WorkGroupsDayListState {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            controller: tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.weekday
                    .substring(0, 2)
                    .toUpperCase()), // Show all weekday names
              );
            }).toList(),
          ),
          // Tab bar views
          body: TabBarView(
            controller: tabController,
            // List of days
            children: widget.days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  // List of work groups
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
                                  // Work group name
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
                                  // Work group meet time
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
                                  // Work groups participants
                                  Container(
                                    width: constraints.maxWidth * 0.25,
                                    child: Text(
                                      workgroup.participants,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  // Work group place
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
