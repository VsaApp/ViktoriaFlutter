import 'package:flutter/material.dart';
import '../CafetoriaModel.dart';
import '../../Localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DayCard extends StatelessWidget {
  const DayCard({Key key, this.day}) : super(key: key);

  final CafetoriaDay day;

  @override
  Widget build(BuildContext context) {
    String menues = '';
    day.menues.forEach((menu) => menues += (menu.price > 0) ? '${menu.name} (${menu.price}€)\n\n' : '${menu.name}\n\n');
    menues = menues.trim();
    if (menues.length == 0) menues = AppLocalizations.of(context).cafetoriaNoMenues;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Card(
        child: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.restaurant_menu, color: Theme.of(context).accentColor),
                title: Text(day.weekday),
                subtitle: Text(menues),
                onTap: () => launch('https://www.opc-asp.de/vs-aachen/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

