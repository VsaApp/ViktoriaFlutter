import 'package:flutter/material.dart';
import '../data/UnitPlan.dart' as UnitPlan;
import '../data/ReplacementPlan.dart' as ReplacementPlan;

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadingPageState();
  }
}

class LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    downloadAll().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    });
    super.initState();
  }

  Future downloadAll() async {
    await UnitPlan.download();
    await ReplacementPlan.download();
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
