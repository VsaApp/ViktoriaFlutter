import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

import 'package:viktoriaflutter/Utils/Models.dart';

/// A card to show the work groups for one day
class WorkGroupsDayCard extends StatelessWidget {
  // ignore: public_member_api_docs
  const WorkGroupsDayCard({
    @required this.day,
    @required this.showWeekday,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final WorkGroupsDay day;
  // ignore: public_member_api_docs
  final bool showWeekday;

  @override
  Widget build(BuildContext context) {
    final List<Widget> workGroups = day.data
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
                if (workGroup.place != '' && workGroup.time != '')
                  Text('${workGroup.place}: ${workGroup.time}')
                else
                  workGroup.place != '' && workGroup.time == ''
                      ? Text(workGroup.place)
                      : workGroup.place == '' && workGroup.time != ''
                          ? Text(workGroup.time)
                          : Container(),
                if (day.data.indexOf(workGroup) != day.data.length - 1) Text(''),
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
                        child: Text(
                            AppLocalizations.of(context).weekdays[day.weekday]),
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
