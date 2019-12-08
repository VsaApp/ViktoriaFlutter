import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Widgets/AppBar.dart';
import 'package:viktoriaflutter/Utils/Widgets/WeekdayTabBar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((a) {
      GlobalAppBar.updateBottom(
        WeekdayTabBar(
          key: ValueKey(widget.weekdays.length),
          weekdays: widget.weekdays,
          controller: widget.controller,
        ),
      );
    });
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
      return TabBarView(
          controller: widget.controller,
          children: widget.tabs.map((tab) {
            return RefreshIndicator(
              onRefresh: widget.onUpdate,
              child: Container(
                color: Colors.white,
                child: tab,
              ),
            );
          }).toList());
    }
  }
}
