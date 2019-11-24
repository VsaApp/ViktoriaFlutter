import 'package:flutter/material.dart';

/// Defines a tab bar view for mobile and desktop
class TabProxy extends StatefulWidget {
  // ignore: public_member_api_docs
  final List<Widget> tabs;
  // ignore: public_member_api_docs
  final TabController controller;

  /// Update listener
  final Function onUpdate;

  /// List of all weekday strings in the user language
  final List<String> weekdays;

  // ignore: public_member_api_docs
  const TabProxy({
    @required this.tabs,
    @required this.controller,
    @required this.onUpdate,
    @required this.weekdays,
  }) : super();

  @override
  State<StatefulWidget> createState() => TabProxyState();
}

// ignore: public_member_api_docs
class TabProxyState extends State<TabProxy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 960) {
      return RefreshIndicator(
        onRefresh: widget.onUpdate,
        child: Container(
          child: Row(
            children: widget.tabs
                .map((tab) => Expanded(
                      flex: 1,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topCenter,
                            color: Theme.of(context).primaryColor,
                            height: 25,
                            child: Text(
                              widget.weekdays[widget.tabs.indexOf(tab)],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            alignment: Alignment.topCenter,
                            child: tab,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    } else {
      return DefaultTabController(
        length: widget.tabs.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          // Tab bar views
          appBar: TabBar(
            controller: widget.controller,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.weekdays.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text(day), // Show all weekday names
              );
            }).toList(),
          ),
          body: TabBarView(
            controller: widget.controller,
            // List of days
            children: widget.tabs.map((tab) {
              return RefreshIndicator(
                onRefresh: widget.onUpdate,
                child: Container(
                  height: double.infinity,
                  color: Colors.white,
                  child: tab,
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}
