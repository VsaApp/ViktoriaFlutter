import 'package:flutter/material.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import 'BrotherSisterReplacementPlanView.dart';
import '../ReplacementPlan/ReplacementPlanData.dart';
import '../UnitPlan/UnitPlanData.dart' as unitPlan;

class BrotherSisterReplacementPlanPage extends StatefulWidget {
  final String grade;

  BrotherSisterReplacementPlanPage({Key key, @required this.grade}): super(key: key);

  @override
  BrotherSisterReplacementPlanPageView createState() => BrotherSisterReplacementPlanPageView();
}

abstract class BrotherSisterReplacementPlanPageState extends State<BrotherSisterReplacementPlanPage> {
  List<ReplacementPlanDay> days;

  @override
  void initState() {
    // Download the replacementplan temp...
    download(widget.grade, alreadyLoad: false).then((_) async {
      load(widget.grade, temp: true, forDays: (await unitPlan.download(grade: widget.grade, setStatic: false)))
          .then((d) {
        setState(() {
          days = d;
          days.forEach((ReplacementPlanDay day) => day.setColors());
        });
      });
    });
    super.initState();
  }
}
