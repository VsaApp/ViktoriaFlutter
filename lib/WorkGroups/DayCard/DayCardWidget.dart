import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../WorkGroupsModel.dart';

class DayCard extends StatelessWidget {
  const DayCard({Key key, this.day}) : super(key: key);

  final WorkGroupsDay day;

  @override
  Widget build(BuildContext context) {
    List<Widget> workGroups = day.data
        .map((workGroup) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  workGroup.name +
                      (workGroup.participants != ''
                          ? ' (${workGroup.participants})'
                          : ''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                workGroup.place != '' && workGroup.time != ''
                    ? Text(workGroup.place + ': ' + workGroup.time)
                    : workGroup.place != '' && workGroup.time == ''
                        ? Text(workGroup.place)
                        : workGroup.place == '' && workGroup.time != ''
                            ? Text(workGroup.time)
                            : Container(),
                day.data.indexOf(workGroup) != day.data.length - 1
                    ? Text('')
                    : Container(),
              ],
            ))
        .toList();
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Card(
        child: Container(
          padding: EdgeInsets.only(bottom: 5),
          child: ListTile(
            leading:
                Icon(MdiIcons.soccer, color: Theme.of(context).accentColor),
            title: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(day.weekday),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: workGroups,
            ),
          ),
        ),
      ),
    );
  }
}
