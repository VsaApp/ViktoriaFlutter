import 'package:flutter/material.dart';
import '../Localizations.dart';
import 'UnitPlanData.dart';
import 'UnitPlanPage.dart';
import 'UnitPlanDayList/UnitPlanDayListWidget.dart';

class UnitPlanView extends UnitPlanState {
  @override
  Widget build(BuildContext context) {
    if (!offlineShown) {
      checkOnline.then((online) {
        offlineShown = true;
        if (!online) {
          // Show offline information
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).oldDataIsShown),
              action: SnackBarAction(
                label: AppLocalizations.of(context).ok,
                onPressed: () {},
              ),
            ),
          );
        }
      });
    }
    return Column(children: <Widget>[UnitPlanDayList(days: getUnitPlan())]);
  }
}
