import 'package:flutter/material.dart';
import '../Network.dart';
import '../Localizations.dart';
import 'UnitPlanDayList/UnitPlanDayListWidget.dart';
import 'UnitPlanData.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  bool offlineShown = false;
  
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
