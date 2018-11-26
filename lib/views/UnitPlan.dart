import 'package:flutter/material.dart';
import '../data/UnitPlan.dart';

class UnitPlanPage extends StatefulWidget {
  @override
  UnitPlanView createState() => UnitPlanView();
}

class UnitPlanView extends State<UnitPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder<List<UnitPlanDay>>(
          future: fetchDays(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? UnitPlanDayList(days: snapshot.data)
                : Container();
          },
        )
      ],
    );
  }
}

class UnitPlanDayList extends StatelessWidget {
  final List<UnitPlanDay> days;

  UnitPlanDayList({Key key, this.days}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Expanded(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: days.map((day) {
              return Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                child: Text(day.name.substring(0, 2).toUpperCase()),
              );
            }).toList(),
          ),
          body: TabBarView(
            children: days.map((day) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Text(day.name),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
