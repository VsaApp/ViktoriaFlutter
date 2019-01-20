import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import 'BrotherSisterReplacementPlanPage.dart';
import '../ReplacementPlan/ReplacementPlanDayList/ReplacementPlanDayListWidget.dart';

class BrotherSisterReplacementPlanPageView extends BrotherSisterReplacementPlanPageState {
  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade),
        elevation: 0.0,
      ),
      body: Hero(
        tag: 'replacementplan-' + widget.grade,
        child: Column(
          children: <Widget>[ReplacementPlanDayList(days: days, sort: false)]),
      ),
    );
  }
}
