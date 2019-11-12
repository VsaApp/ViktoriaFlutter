import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/Models.dart';

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
    List<Widget> menus = day.menus
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
                day.menus.indexOf(menu) != day.menus.length - 1
                    ? Text('')
                    : Container(),
              ],
            ))
        .toList();
    if (menus.length == 0) {
      menus = [
        Text(
          AppLocalizations.of(context).cafetoriaNoMenus,
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
                        child: Text(AppLocalizations.of(context).weekdays[day.day]),
                      )
                    : null,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: menus,
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
