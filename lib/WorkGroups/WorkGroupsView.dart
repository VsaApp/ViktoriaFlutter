import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Models/Models.dart';
import 'DayCard/DayCardWidget.dart';
import 'WorkGroupsPage.dart';

// ignore: public_member_api_docs
class WorkGroupsPageView extends WorkGroupsPageState {
  /// The refresh indicator key to refresh programmatically
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
