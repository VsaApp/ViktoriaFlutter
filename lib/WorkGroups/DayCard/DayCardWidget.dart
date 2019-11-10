import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:viktoriaflutter/Utils/Models/WorkGroupsModel.dart';

class WorkGroupsDayCard extends StatelessWidget {
  const WorkGroupsDayCard({
    Key key,
    @required this.day,
    @required this.showWeekday,
  }) : super(key: key);

  final WorkGroupsDay day;
  final bool showWeekday;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading:
                    Icon(MdiIcons.soccer, color: Theme.of(context).accentColor),
                title: showWeekday
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(day.weekday),
                      )
                    : null,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: workGroups,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
