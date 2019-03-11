import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Keys.dart';
import './HistoryDialogModel.dart';
import './HistoryDialogView.dart';
import './HistoryDialogData.dart';
import '../../UnitPlan/UnitPlanData.dart' as Unitplan;

class HistoryDialog extends StatefulWidget {
  final String type;

  HistoryDialog({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HistoryDialogView();
}

abstract class HistoryDialogState extends State<HistoryDialog> {
  SharedPreferences sharedPreferences;
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
          .times
        ..sort((a, b) {
          return (int.parse(a.time.split(':')[0]) * 60 +
                  int.parse(a.time.split(':')[1]))
              .compareTo((int.parse(b.time.split(':')[0]) * 60 +
                  int.parse(b.time.split(':')[1])));
        });
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
      setState(() => data = years);
      SharedPreferences.getInstance().then((instance) {
        setState(() {
          sharedPreferences = instance;
          List<String> currentDate =
              sharedPreferences.getStringList(Keys.historyDate(widget.type));
          if (currentDate != null) {
            currentYear = currentDate[0];
            currentMonth = currentDate[1];
            currentDay = currentDate[2];
            currentTime = currentDate[3];
            loadNewestData = false;
          } else if (widget.type == 'unitplan') {
            Unitplan.fetchDate(sharedPreferences.getString(Keys.grade))
                .then((String date) {
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
    });
    super.initState();
  }
}
