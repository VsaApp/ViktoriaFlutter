import 'package:flutter/material.dart';

import 'DayCard/DayCardWidget.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'WorkGroupsPage.dart';

class WorkGroupsPageView extends WorkGroupsPageState {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: update,
      child: ListView(
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        children: Data.workGroups.days
            .map((day) => WorkGroupsDayCard(
                  day: day,
                  showWeekday: true,
                ))
            .toList(),
      ),
    );
  }
}
