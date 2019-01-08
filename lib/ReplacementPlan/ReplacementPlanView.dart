import 'package:flutter/material.dart';
import '../BrotherSisterReplacementPlan/BrotherSisterReplacementPlanPage.dart';
import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanData.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import 'ReplacementPlanDayList/ReplacementPlanDayListWidget.dart';
import 'ReplacementPlanPage.dart';
import 'GradeFAB/GradeFABWidget.dart';

class ReplacementPlanPageView extends ReplacementPlanPageState {
  @override
  Widget build(BuildContext context) {
    List<ReplacementPlanDay> data = getReplacementPlan();
    return new Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[ReplacementPlanDayList(days: data)],
        ),
        // FAB
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Container(
              child: GradeFab(
                onSelectPressed: (Function(String grade) selected) {
                  // Select a grade to show the replacement plan of
                  showDialog<String>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context1) {
                        return SimpleDialog(
                          title:
                              Text(AppLocalizations.of(context).pleaseSelect),
                          children: ReplacementPlanPageState.grades.map((_grade) {
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
                },
                onSelected: (String grade) {
                  // Show replacement plan for another grade
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          BrotherSisterReplacementPlanPage(grade: grade)));
                },
              ),
            )),
      ]),
    );
  }
}
