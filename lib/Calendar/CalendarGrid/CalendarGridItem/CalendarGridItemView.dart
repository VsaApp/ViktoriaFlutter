import 'package:flutter/material.dart';

import '../../../Localizations.dart';
import '../../EventCard/EventCard.dart';
import 'CalendarGridItemWidget.dart';

class CalendarGridItemView extends CalendarGridItemState {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (getEvents().length > 0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
                title: Text(widget.date.day.toString() +
                    '.' +
                    widget.date.month.toString() +
                    '.' +
                    widget.date.year.toString()),
                content: ListView(
                  shrinkWrap: true,
                  children: getEvents()
                      .map((event) => EventCard(event: event))
                      .toList(),
                ),
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
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade500),
            bottom: BorderSide(color: Colors.grey.shade500),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Text(
              widget.date.day.toString(),
              style: TextStyle(
                color: !widget.main
                    ? Colors.grey.shade400
                    : Theme.of(context).primaryColor,
                fontWeight: widget.main ? FontWeight.bold : null,
              ),
            ),
            getEvents().length == 1
                ? Center(
                    child: SizedBox(
                      height: 12.5,
                      width: 12.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                : getEvents().length > 0
                    ? Center(
                        child: Text(
                          getEvents().length.toString(),
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
