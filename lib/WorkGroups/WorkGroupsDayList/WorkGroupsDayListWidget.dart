import 'package:flutter/material.dart';

import '../WorkGroupsData.dart';
import '../WorkGroupsModel.dart';
import 'WorkGroupsDayListView.dart';

class WorkGroupsDayList extends StatefulWidget {
  List<WorkGroupsDay> days;

  WorkGroupsDayList({Key key, this.days}) : super(key: key);

  @override
  WorkGroupsDayListView createState() => WorkGroupsDayListView();
}

abstract class WorkGroupsDayListState extends State<WorkGroupsDayList>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  Future update() async {
    await download();
    setState(() => widget.days = getWorkGroups());
  }

  @override
  void initState() {
    // Select correct tab
    tabController = TabController(vsync: this, length: widget.days.length);
    int weekday = DateTime.now().weekday - 1;
    if (weekday > 4) {
      weekday = 0;
    }
    tabController.animateTo(weekday);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
