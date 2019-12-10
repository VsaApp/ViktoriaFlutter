import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

import '../../EventCard/EventCard.dart';
import 'CalendarGridItemWidget.dart';

// ignore: public_member_api_docs
class CalendarGridItemView extends CalendarGridItemState {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (getEvents().isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
                title: Text(
                    '${widget.date.day.toString()}.${widget.date.month.toString()}.${widget.date.year.toString()}'),
                content: ListView(
                  shrinkWrap: true,
                  children: getEvents()
                      .map((event) => EventCard(event: event))
                      .toList(),
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context).ok,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: isToday()
              ? Colors.blue.shade100
              : widget.main ? null : Colors.grey.shade100,
          border: Border(
            right: BorderSide(
                color: isToday() || isYesterday()
                    ? Colors.blue.shade500
                    : Colors.grey.shade500),
            bottom: BorderSide(
                color:
                    !isToday() ? Colors.grey.shade500 : Colors.blue.shade500),
          ),
        ),
        child: Text(
          widget.date.day.toString(),
          style: TextStyle(
            color: !widget.main
                ? Colors.grey.shade400
                : isToday() ? Colors.blue : Theme.of(context).primaryColor,
            fontWeight: widget.main ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}
