import 'package:flutter/material.dart';

import '../../Keys.dart';
import '../../Localizations.dart';
import './HistoryDialogWidget.dart';
import './HistoryDialogModel.dart';

class HistoryDialogView extends HistoryDialogState {
  @override
  Widget build(BuildContext context) {
    // Show the shortcut dialog
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).selectDate),
      children: <Widget>[
        data == null || currentYear == null || sharedPreferences == null ? 
        // Show loader
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(strokeWidth: 5.0),
                height: 75.0,
                width: 75.0,
              )
            );
          }
        )
        :
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            print(data.map((year) => year.name));
            print('$currentTime Uhr - $currentDay.$currentMonth.$currentYear');
            return Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: Center(child: Text(AppLocalizations.of(context).year))
                    ),
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isDense: true,
                          value: currentYear,
                          onChanged: loadNewestData ? null : (String year) {
                            setState(() {
                              currentYear = year;
                              currentMonth = months[months.length - 1].name;
                              currentDay = days[days.length - 1].name;
                              currentTime = times[times.length - 1].time;
                            });
                          },
                          items: years.map((Year year) => DropdownMenuItem(
                              value: year.name,
                              child: Text(year.name)
                            )
                          ).toList(),
                        )
                      )
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: Center(child: Text(AppLocalizations.of(context).month))
                    ),
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: DropdownButton<String>(
                        isDense: true,
                        value: currentMonth,
                        onChanged: loadNewestData ? null : (String month) {
                          setState(() {
                            currentMonth = month;
                            currentDay = days[days.length - 1].name;
                            currentTime = times[times.length - 1].time;                          
                          });
                        },
                        items: months.map((Month month) => DropdownMenuItem(
                            value: month.name,
                            child: Text(month.name)
                          )
                        ).toList(),
                      )
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: Center(child: Text(AppLocalizations.of(context).day))
                    ),
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: DropdownButton<String>(
                        isDense: true,
                        value: currentMonth,
                        onChanged: loadNewestData ? null : (String day) {
                          setState(() {
                            currentDay = day;
                            currentTime = times[times.length - 1].time;                          
                          });
                        },
                        items: days.map((Day day) => DropdownMenuItem(
                            value: day.name,
                            child: Text(day.name)
                          )
                        ).toList(),
                      )
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: Center(child: Text(AppLocalizations.of(context).time))
                    ),
                    Container(
                      width: constraints.maxWidth * 0.20,
                      child: DropdownButton<String>(
                        isDense: true,
                        value: currentMonth,
                        onChanged: loadNewestData ? null : (String time) {
                          setState(() {
                            currentTime = time;                          
                          });
                        },
                        items: times.map((Time time) => DropdownMenuItem(
                            value: time.time,
                            child: Text(time.time)
                          )
                        ).toList(),
                      )
                    )
                  ],
                )
              ],
            );
          }
        )
      ]
    );
  }
}
