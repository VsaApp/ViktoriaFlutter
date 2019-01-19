import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UnitPlanModel.dart';
import 'UnitPlanRowView.dart';

class UnitPlanRow extends StatefulWidget {
  final UnitPlanSubject subject;
  final int unit;
  final bool showUnit;
  final int weekday;

  UnitPlanRow({
    Key key,
    @required this.subject,
    @required this.unit,
    @required this.weekday,
    this.showUnit = true,
  }) : super(key: key);

  @override
  UnitPlanRowView createState() => UnitPlanRowView();
}

abstract class UnitPlanRowState extends State<UnitPlanRow> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      if (!mounted) return;
      setState(() {
        sharedPreferences = instance;
      });
    });
    super.initState();
  }
}
