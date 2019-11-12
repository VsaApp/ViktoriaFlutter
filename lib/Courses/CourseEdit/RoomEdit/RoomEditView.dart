import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Rooms.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

class RoomEdit extends StatefulWidget {
  final subject;

  RoomEdit({
    Key key,
    this.subject,
  }) : super(key: key);

  @override
  RoomEditView createState() => RoomEditView();
}

class RoomEditView extends State<RoomEdit> {
  String room;

  @override
  void initState() {
    super.initState();
    setState(() {
      room = getRoom(
        widget.subject['weekday'],
        widget.subject['unit'],
        widget.subject['subject'].unit,
        widget.subject['subject'].roomID,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text([
                'Montag',
                'Dienstag',
                'Mittwoch',
                'Donnerstag',
                'Freitag'
              ][widget.subject['weekday']] +
              ' ' +
              (widget.subject['unit'] + 1).toString() +
              '. Stunde (Normal: ' +
              widget.subject['subject'].roomID +
              '):'),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                items: Data.rooms.values.toSet().toList().map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: room,
                onChanged: (value) {
                  setState(() {
                    room = value;
                    setRoom(
                      widget.subject['weekday'],
                      widget.subject['unit'],
                      widget.subject['subject'].unit,
                      value,
                    );
                    syncTags();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
