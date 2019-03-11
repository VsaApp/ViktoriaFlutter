import 'package:flutter/material.dart';

import '../../UnitPlan/UnitPlanData.dart' as unitplan;
import '../../ReplacementPlan/ReplacementPlanData.dart' as replacementplan;
import '../../Keys.dart';
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
                  child: CircularProgressIndicator(strokeWidth: 1.0),
                  height: 25.0,
                  width: 25.0,
                ),
              )
            : Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      value: loadNewestData,
                      onChanged: (bool value) {
                        setState(() {
                          loadNewestData = value;
                        });
                      },
                      title: Text(AppLocalizations.of(context).loadNewestData),
                    ),
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
                                onChanged: loadNewestData
                                    ? null
                                    : (year) {
                                        setState(() {
                                          currentYear = year;
                                          currentMonth =
                                              months[months.length - 1].name;
                                          currentDay =
                                              days[days.length - 1].name;
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
                                onChanged: loadNewestData
                                    ? null
                                    : (month) {
                                        setState(() {
                                          currentMonth = month;
                                          currentDay =
                                              days[days.length - 1].name;
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
                                onChanged: loadNewestData
                                    ? null
                                    : (day) {
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
                                      onChanged: loadNewestData
                                          ? null
                                          : (time) {
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
                    FlatButton(
                      color: Theme.of(context).accentColor,
                      child: Text(AppLocalizations.of(context).ok,
                          style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        if (loadNewestData &&
                            sharedPreferences.getStringList(
                                    Keys.historyDate(widget.type)) !=
                                null) {
                          sharedPreferences
                              .remove(Keys.historyDate(widget.type));
                        } else if (!loadNewestData) {
                          String fileName;
                          if (widget.type == 'unitplan') {
                            Day day = days.firstWhere(
                                (Day day) => day.name == currentDay);
                            fileName = day.files[day.files.length - 1].name;
                          } else {
                            int index = unsortedTimes
                                .map((Time time) => time.time)
                                .toList()
                                .indexOf(currentTime);
                            fileName = days
                                .firstWhere((Day day) => day.name == currentDay)
                                .files[index]
                                .name;
                          }
                          sharedPreferences.setStringList(
                              Keys.historyDate(widget.type), [
                            currentYear,
                            currentMonth,
                            currentDay,
                            currentTime,
                            fileName
                          ]);
                        }
                        Navigator.of(context).pop();
                        Function() update = () async {
                          await unitplan.download(
                              sharedPreferences.getString(Keys.grade), false);
                          await replacementplan.load(
                              unitplan.getUnitPlan(), false);
                        };
                        update();
                      },
                    )
                  ],
                ),
              ),
      ],
    );
  }
}
