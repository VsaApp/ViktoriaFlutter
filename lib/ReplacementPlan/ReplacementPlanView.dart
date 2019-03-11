import 'package:flutter/material.dart';

import '../BrotherSisterReplacementPlan/BrotherSisterReplacementPlanPage.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../Network.dart';
import '../ReplacementPlan/ReplacementPlanData.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import 'GradeFAB/GradeFABWidget.dart';
import 'ReplacementPlanDayList/ReplacementPlanDayListWidget.dart';
import 'ReplacementPlanPage.dart';

class ReplacementPlanPageView extends ReplacementPlanPageState {
  @override
  Widget build(BuildContext context) {
    List<ReplacementPlanDay> data = getReplacementPlan();
    if (sharedPreferences == null) return Container();
    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            ReplacementPlanDayList(
                days: data,
                sort: sharedPreferences.getBool(Keys.sortReplacementPlan))
          ],
        ),
        // FAB
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Container(
              child: GradeFab(
                onSelectPressed: (Function(String grade) selected) async {
                  // Select a grade to show the replacement plan of
                  int online = await checkOnline;
                  if (online != 1) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(online == -1
                            ? AppLocalizations.of(context).onlyOnline
                            : AppLocalizations.of(context).serverIsOffline),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context).ok,
                          onPressed: () {},
                        ),
                      ),
                    );
                  } else {
                    showDialog<String>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context1) {
                          return SimpleDialog(
                            title:
                                Text(AppLocalizations.of(context).pleaseSelect),
                            children:
                                ReplacementPlanPageState.grades.map((_grade) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  print(_grade);
                                  selected(_grade);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          BrotherSisterReplacementPlanPage(
                                              grade: _grade)));
                                },
                                child: Text(_grade),
                              );
                            }).toList(),
                          );
                        });
                  }
                },
                onSelected: (String grade) async {
                  int online = await checkOnline;
                  if (online != 1) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(online == -1
                            ? AppLocalizations.of(context).onlyOnline
                            : AppLocalizations.of(context).serverIsOffline),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context).ok,
                          onPressed: () {},
                        ),
                      ),
                    );
                  } else {
                    // Show replacement plan for another grade
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            BrotherSisterReplacementPlanPage(grade: grade)));
                  }
                },
              ),
            )),
      ]),
    );
  }
}
