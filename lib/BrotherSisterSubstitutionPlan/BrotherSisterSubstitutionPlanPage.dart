import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'BrotherSisterSubstitutionPlanView.dart';

/// Page for a substitution plan for other grades
class BrotherSisterSubstitutionPlanPage extends StatefulWidget {
  /// The grade to show
  final String grade;

  // ignore: public_member_api_docs
  const BrotherSisterSubstitutionPlanPage({@required this.grade, Key key})
      : super(key: key);

  @override
  BrotherSisterSubstitutionPlanPageView createState() =>
      BrotherSisterSubstitutionPlanPageView();
}

// ignore: public_member_api_docs
abstract class BrotherSisterSubstitutionPlanPageState
    extends State<BrotherSisterSubstitutionPlanPage>
    with SingleTickerProviderStateMixin {

  /// The loaded substitution plan days
  List<SubstitutionPlanDay> days;

  /// The tab controller for the substitution plan days
  TabController controller;

  @override
  void initState() {
    days = Data.substitutionPlan.days;
    controller = TabController(vsync: this, length: days.length);
    super.initState();
  }
}
