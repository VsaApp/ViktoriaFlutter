import 'package:flutter/material.dart';

import '../../Localizations.dart';
import 'CalendarGridItem/CalendarGridItemWidget.dart';
import 'CalendarGridWidget.dart';

class CalendarGridView extends CalendarGridState {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double headerHeight = 36;
          double otherPadding = 10;
          double height = constraints.maxHeight - headerHeight - otherPadding -
              1;
          double width = constraints.maxWidth - otherPadding * 2 - 1;

          List<Widget> tabs = [];
          for (int i = 0; i < lastEvent.month - firstEvent.month + 1; i++) {
            int month = i + firstEvent.month - 1;
            int days = daysInMonth(month, firstEvent.year);
            DateTime firstDayInMonth = DateTime(firstEvent.year, month + 1, 1);
            List<Widget> items = [];
            for (int j = 0; j < firstDayInMonth.weekday - 1; j++) {
              DateTime date = firstDayInMonth
                  .subtract(Duration(days: firstDayInMonth.weekday - 1 - j));
              items.add(CalendarGridItem(date: date, main: false));
            }
            for (int k = 0; k < days; k++) {
              DateTime date = firstDayInMonth.add(Duration(days: k));
              items.add(CalendarGridItem(date: date, main: true));
            }
            int l = 0;
            while (items.length < 42) {
              DateTime date =
              DateTime(firstDayInMonth.year, firstDayInMonth.month + 1, 1)
                  .add(Duration(days: l++));
              items.add(CalendarGridItem(date: date, main: false));
            }
            List<List<Widget>> rows = [];
            for (int m = 0; m < 6; m++) {
              List<Widget> column = [];
              for (int n = 0; n < 7; n++) {
                column.add(items[m * 7 + n]);
              }
              rows.add(column);
            }
            tabs.add(Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    AppLocalizations
                        .of(context)
                        .months[month],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade500),
                      left: BorderSide(color: Colors.grey.shade500),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    right: otherPadding,
                    bottom: otherPadding,
                    left: otherPadding,
                  ),
                  child: Column(
                    children: rows
                        .map((row) =>
                        Row(
                            children: row
                                .map((item) =>
                                SizedBox(
                                  width: width / 7,
                                  height: height / 6,
                                  child: item,
                                ))
                                .toList()))
                        .toList(),
                  ),
                ),
              ],
            ));
          }
          return TabBarView(
            controller: controller,
            children: tabs,
          );
        });
  }
}
