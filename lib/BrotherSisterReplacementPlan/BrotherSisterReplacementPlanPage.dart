import 'package:flutter/material.dart';

import '../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../UnitPlan/UnitPlanData.dart' as unitplan;
import 'BrotherSisterReplacementPlanView.dart';

class BrotherSisterReplacementPlanPage extends StatefulWidget {
  final String grade;

  BrotherSisterReplacementPlanPage({Key key, @required this.grade})
      : super(key: key);

  @override
  BrotherSisterReplacementPlanPageView createState() =>
      BrotherSisterReplacementPlanPageView();
}

abstract class BrotherSisterReplacementPlanPageState
    extends State<BrotherSisterReplacementPlanPage> {
  List<ReplacementPlanDay> days;

  @override
  void initState() {
    unitplan.download(widget.grade, true).then((days1) {
      replacementplan.load(days1, true).then((days2) {
        setState(() {
          days = days2;
        });
      });
    });
    super.initState();
  }
}
