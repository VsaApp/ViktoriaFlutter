import 'package:flutter/material.dart';
import '../data/UnitPlan.dart' as UnitPlan;

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadingPageState();
  }
}

class LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    downloadUnitPlan().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    });
    super.initState();
  }

  Future downloadUnitPlan() async {
    await UnitPlan.download();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: new CircularProgressIndicator(strokeWidth: 5.0),
          height: 75.0,
          width: 75.0,
        ),
      ),
    );
  }
}
