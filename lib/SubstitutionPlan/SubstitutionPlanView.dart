import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Home/HomePage.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Update.dart';

import 'package:viktoriaflutter/BrotherSisterSubstitutionPlan/BrotherSisterSubstitutionPlanPage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Network.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/TabProxy.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Downloader/SubstitutionPlanData.dart';
import 'package:viktoriaflutter/SubstitutionPlan/GradeFAB/GradeFABWidget.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanDayList/SubstitutionPlanDayListWidget.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanPage.dart';

// ignore: public_member_api_docs
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
              .map((day) => SubstitutionPlanDayList(
                    day: day,
                    dayIndex: days.indexOf(day),
                    grade: Storage.getString(Keys.grade),
                    sort: Storage.getBool(Keys.sortSubstitutionPlan),
                  ))
              .toList(),
          controller: controller,
          onUpdate: () async {
            await syncWithTags();
            final bool successfully =
                await SubstitutionPlanData().download(context) ==
                    StatusCodes.success;
            dataUpdated(context, successfully,
                AppLocalizations.of(context).substitutionPlan);
            setState(() =>
                days = generateDays(Data.substitutionPlan.days));
          },
        ),
        // FAB
        Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              child: GradeFab(
                onSelectPressed: (Function(String grade) selected) async {
                  // Select a grade to show the substitution plan of
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
                },
                onSelected: (String grade) async {
                  final int online = await checkOnline;
                  if (online != 1 && HomePageState.isInForeground) {
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
