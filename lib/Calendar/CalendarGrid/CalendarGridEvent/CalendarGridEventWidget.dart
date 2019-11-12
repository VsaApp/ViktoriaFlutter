import 'package:flutter/material.dart';
import '../../EventCard/EventCard.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

class CalendarGridEvent extends StatelessWidget {
  final CalendarEvent event;

  CalendarGridEvent({this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
                title: Text(AppLocalizations.of(context).event),
                content: ListView(
                    shrinkWrap: true,
                    children: <Widget>[EventCard(event: event)]),
                actions: <Widget>[
                  FlatButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        AppLocalizations.of(context).ok,
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              );
            },
          );
        },
        child: Container(
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border(
                right: BorderSide(color: Colors.green.shade500),
                left: BorderSide(color: Colors.green.shade500),
                top: BorderSide(color: Colors.green.shade500),
                bottom: BorderSide(color: Colors.green.shade500),
              ),
            ),
            child: Text(
              event.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 12),
            )));
  }
}
