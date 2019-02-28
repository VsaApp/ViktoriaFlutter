import 'package:flutter/material.dart';

import '../../Localizations.dart';
import './HistoryDialogWidget.dart';
import './HistoryDialogModel.dart';

class HistoryDialogView extends HistoryDialogState {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).selectDate),
      children: <Widget>[
        data == null ||
                currentYear == null ||
                currentMonth == null ||
                currentDay == null ||
                sharedPreferences == null
            ?
            // Show loader
            Center(
                child: SizedBox(
                  child: CircularProgressIndicator(strokeWidth: 5.0),
                  height: 75.0,
                  width: 75.0,
                ),
              )
            : Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).year),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                items: years.toList().map((Year year) {
                                  return DropdownMenuItem<String>(
                                    value: year.name,
                                    child: Text(year.name),
                                  );
                                }).toList(),
                                value: currentYear.toString(),
                                onChanged: (year) {
                                  setState(() {
                                    currentYear = year;
                                    currentMonth =
                                        months[months.length - 1].name;
                                    currentDay = days[days.length - 1].name;
                                    if (currentTime != null) {
                                      currentTime =
                                          times[times.length - 1].time;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).month),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: currentMonth.toString(),
                                onChanged: (month) {
                                  setState(() {
                                    currentMonth = month;
                                    currentDay = days[days.length - 1].name;
                                    if (currentTime != null) {
                                      currentTime =
                                          times[times.length - 1].time;
                                    }
                                  });
                                },
                                items: months
                                    .map(
                                      (Month month) => DropdownMenuItem(
                                            value: month.name,
                                            child: Text(month.name),
                                          ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).day),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: currentDay.toString(),
                                onChanged: (day) {
                                  setState(() {
                                    currentDay = day;
                                    if (currentTime != null) {
                                      currentTime =
                                          times[times.length - 1].time;
                                    }
                                  });
                                },
                                items: days
                                    .map(
                                      (Day day) => DropdownMenuItem(
                                            value: day.name,
                                            child: Text(day.name),
                                          ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    currentTime == null
                        ? Container()
                        : Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).time),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isDense: true,
                                      value: currentTime,
                                      onChanged: (time) {
                                        setState(() {
                                          currentTime = time;
                                        });
                                      },
                                      items: times
                                          .toList()
                                          .map((a) => a.time)
                                          .toSet()
                                          .map((time) {
                                        return DropdownMenuItem(
                                          value: time,
                                          child: Text(time),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
      ],
    );
  }
}
