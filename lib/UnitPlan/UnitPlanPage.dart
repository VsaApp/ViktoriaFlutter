import 'package:flutter/material.dart';
import '../Network.dart';
import '../Localizations.dart';
import 'UnitPlanDayList/UnitPlanDayListWidget.dart';
import 'UnitPlanData.dart';
import '../Home/HomePage.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  Function() listener;
  static bool offlineShown = false;

  @override
  void initState() {
    listener = () => setState(() => null);
    HomePageState.replacementplanUpdatedListeners.add(listener);
    super.initState();
  }

  @override
  void dispose() {
    HomePageState.replacementplanUpdatedListeners.remove(listener);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!offlineShown) {
      checkOnline.then((online) {
        offlineShown = true;
        if (online != 1) {
          // Show offline information
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(online == -1 ? AppLocalizations.of(context).oldDataIsShown : AppLocalizations.of(context).serverIsOffline),
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
