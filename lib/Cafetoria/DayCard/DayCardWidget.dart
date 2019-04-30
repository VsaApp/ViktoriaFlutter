import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../CafetoriaModel.dart';

class CafetoriaDayCard extends StatelessWidget {
  const CafetoriaDayCard({
    Key key,
    @required this.day,
    @required this.showWeekday,
  }) : super(key: key);

  final CafetoriaDay day;
  final bool showWeekday;

  @override
  Widget build(BuildContext context) {
    List<Widget> menues = day.menues
        .map((menu) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  menu.name +
                      (menu.price > 0
                          ? ' (${menu.price.toString().replaceAll('.0', '')}€)'
                          : ''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                menu.time != '' ? Text(menu.time) : Container(),
                day.menues.indexOf(menu) != day.menues.length - 1
                    ? Text('')
                    : Container(),
              ],
            ))
        .toList();
    if (menues.length == 0) {
      menues = [
        Text(
          AppLocalizations.of(context).cafetoriaNoMenues,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(''),
      ];
    }
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
                    Icon(Icons.fastfood, color: Theme.of(context).accentColor),
                title: showWeekday
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(day.weekday),
                      )
                    : null,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: menues,
                ),
                onTap: () => launch('https://www.opc-asp.de/vs-aachen/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
