import 'package:flutter/material.dart';

import 'WorkGroupsData.dart';
import 'WorkGroupsDayList/WorkGroupsDayListWidget.dart';

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
