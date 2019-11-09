import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../../Timetable/TimetableData.dart' as Timetable;
import 'HistoryDialogData.dart';
import 'HistoryDialogModel.dart';
import 'HistoryDialogView.dart';

class HistoryDialog extends StatefulWidget {
  final String type;

  HistoryDialog({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HistoryDialogView();
}

abstract class HistoryDialogState extends State<HistoryDialog> {
  List<Year> data;
  bool loadNewestData = true;
  String currentYear;
  String currentMonth;
  String currentDay;
  String currentTime;

  List<Year> get years {
    return data
      ..sort((a, b) => (int.parse(a.name).compareTo(int.parse(b.name))));
  }

  List<Month> get months {
    try {
      return data
          .where((Year year) => year.name == currentYear)
          .toList()[0]
          .months
        ..sort((a, b) => (int.parse(a.name).compareTo(int.parse(b.name))));
    } catch (e) {
      return [];
    }
  }

  List<Day> get days {
    try {
      return data
          .where((Year year) => year.name == currentYear)
          .toList()[0]
          .months
          .where((Month month) => month.name == currentMonth)
          .toList()[0]
          .days
        ..sort((a, b) => (int.parse(a.name).compareTo(int.parse(b.name))));
    } catch (e) {
      return [];
    }
  }

  List<Time> get times {
    try {
      return data
          .where((Year year) => year.name == currentYear)
          .toList()[0]
          .months
          .where((Month month) => month.name == currentMonth)
          .toList()[0]
          .days
          .where((Day day) => day.name == currentDay)
          .toList()[0]
          .times;
    } catch (e) {
      return [];
    }
  }

  List<Time> get unsortedTimes {
    try {
      return data
          .where((Year year) => year.name == currentYear)
          .toList()[0]
          .months
          .where((Month month) => month.name == currentMonth)
          .toList()[0]
          .days
          .where((Day day) => day.name == currentDay)
          .toList()[0]
          .times;
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    download(widget.type).then((List<Year> years) {
      setState(() {
        data = years;
        List<String> currentDate =
        Storage.getStringList(Keys.historyDate(widget.type));
        if (currentDate != null) {
          currentYear = currentDate[0];
          currentMonth = currentDate[1];
          currentDay = currentDate[2];
          currentTime = currentDate[3];
          loadNewestData = false;
        } else if (widget.type == 'timetable') {
          Timetable.fetchDate(Storage.getString(Keys.grade)).then((String date) {
            setState(() {
              currentYear = '20' + date.split('.')[2];
              currentMonth = date.split('.')[1];
              currentDay = date.split('.')[0];
              currentTime = null;
            });
          });
        } else {
          setState(() {
            currentYear = years[years.length - 1].name;
            currentMonth = months[months.length - 1].name;
            currentDay = days[days.length - 1].name;
            currentTime = times[times.length - 1].time;
          });
        }
      });
    });
    super.initState();
  }
}
