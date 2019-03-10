import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Rooms.dart';
import '../../../Rooms/RoomsModel.dart';

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
  SharedPreferences sharedPreferences;
  String room;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        room = getRoom(
            sharedPreferences,
            widget.subject['weekday'],
            widget.subject['unit'],
            widget.subject['subject'].lesson,
            widget.subject['subject'].room);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
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
              widget.subject['subject'].room +
              '):'),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                items: Rooms.rooms.values.toSet().toList().map((String value) {
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
                        sharedPreferences,
                        widget.subject['weekday'],
                        widget.subject['unit'],
                        widget.subject['subject'].lesson,
                        value);
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