import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'CalendarGridItem/CalendarGridItemWidget.dart';
import 'CalendarGridWidget.dart';

// ignore: public_member_api_docs
class CalendarGridView extends CalendarGridState {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      const headerHeight = 36.0;
      const otherPadding = 0.0;
      final height = constraints.maxHeight - headerHeight - otherPadding - 1;
      final width = constraints.maxWidth - otherPadding * 2 - 1;

      final List<Widget> tabs = [];
      for (int i = 0;
          i <
              lastEvent.month -
                  firstEvent.month +
                  1 +
                  (lastEvent.year - firstEvent.year) * 12;
          i++) {
        final int month = (i + firstEvent.month - 1) % 12;
        final int year = firstEvent.year + ((i + firstEvent.month - 1) ~/ 12);
        final int days = daysInMonth(month, year);
        final DateTime firstDayInMonth = DateTime(year, month + 1, 1);
        final List<CalendarGridItem> items = [];
        for (int j = 0; j < firstDayInMonth.weekday - 1; j++) {
          final DateTime date = firstDayInMonth
              .subtract(Duration(days: firstDayInMonth.weekday - 1 - j));
          items.add(CalendarGridItem(date: date, main: false));
        }
        for (int k = 0; k < days; k++) {
          final DateTime date = firstDayInMonth.add(Duration(days: k));
          items.add(CalendarGridItem(date: date, main: true));
        }
        int l = 0;
        while (items.length < 42) {
          final DateTime date =
              DateTime(firstDayInMonth.year, firstDayInMonth.month + 1, 1)
                  .add(Duration(days: l++));
          items.add(CalendarGridItem(date: date, main: false));
        }
        final List<List<CalendarGridItem>> rows = [];
        for (int m = 0; m < 6; m++) {
          final List<CalendarGridItem> column = [];
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
              width: constraints.maxWidth,
              padding: EdgeInsets.all(10),
              child: Center(
                  child: Text(
                '${AppLocalizations.of(context).months[month]} $year',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              )),
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
                    .map((row) => Stack(
                            children: <Widget>[
                          Row(
                              children: row
                                  .map((item) => SizedBox(
                                        width: width / 7,
                                        height: height / 6,
                                        child: item,
                                      ))
                                  .toList()), ...getEventViewsForWeek(
                                row[0].date, row[6].date, width, height)
                        ]))
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
