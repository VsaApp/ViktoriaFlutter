import 'package:flutter/material.dart';

import '../BrotherSisterSubstitutionPlan/BrotherSisterSubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'GradeFAB/GradeFABWidget.dart';
import 'SubstitutionPlanData.dart' as substitutionPlan;
import 'SubstitutionPlanDayList/SubstitutionPlanDayListWidget.dart';
import 'SubstitutionPlanPage.dart';

class SubstitutionPlanPageView extends SubstitutionPlanPageState {
  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return Container();
    }
    return Scaffold(
      body: Stack(children: <Widget>[
        TabProxy(
          weekdays: weekdays,
          tabs: days
              .map((day) =>
              SubstitutionPlanDayList(
                day: day,
                dayIndex: days.indexOf(day),
                grade: Storage.getString(Keys.grade),
                sort: Storage.getBool(Keys.sortSubstitutionPlan),
              ))
              .toList(),
          controller: controller,
          onUpdate: () async {
            await substitutionPlan.download();
            setState(() =>
            days = generateDays(substitutionPlan.getSubstitutionPlan()));
          },
        ),
        // FAB
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Container(
              child: GradeFab(
                onSelectPressed: (Function(String grade) selected) async {
                  // Select a grade to show the substitution plan of
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
                                SubstitutionPlanPageState.grades.map((_grade) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  print(_grade);
                                  selected(_grade);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          BrotherSisterSubstitutionPlanPage(
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
                    // Show substitution plan for another grade
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            BrotherSisterSubstitutionPlanPage(grade: grade)));
                  }
                },
              ),
            )),
      ]),
    );
  }
}
