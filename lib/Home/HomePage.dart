import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Home/HomeView.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Widgets/AppBar.dart';

/// The home page of the app
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageView();
}

// ignore: public_member_api_docs
abstract class HomePageState extends State<HomePage> {
  /// The current timetable day to show
  TimetableDay currentTtDay;

  /// The current substitution plan day
  SubstitutionPlanDay currentSpDay;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((a) {
      currentTtDay = Data.timetable.days[_getCurrentWeekday()];
      currentSpDay = _getCurrentSpDay();
      GlobalAppBar.updateTitle(AppLocalizations.of(context).home);
      GlobalAppBar.updateBottom(null);
    });
    super.initState();
  }

  SubstitutionPlanDay _getCurrentSpDay() {
    final DateTime cDate = DateTime.now();
    final DateTime date = DateTime(cDate.year, cDate.month, cDate.day);
    final List<SubstitutionPlanDay> futureDays =
        Data.substitutionPlan.days.where((day) {
      return date.isBefore(day.date);
    }).toList();
    if (futureDays.isNotEmpty) {
      if (_dayIsOver(futureDays[0].date.weekday)) {
        if (futureDays.length > 1) {
          return futureDays[1];
        } else {
          return null;
        }
      }
      return futureDays[0];
    }
    return null;
  }

  int _getCurrentWeekday() {
    int weekday = DateTime.now().weekday - 1;
    final bool over = _dayIsOver(weekday);
    if (weekday > 4) {
      weekday = 0;
    } else if (over) {
      weekday++;
    }
    // If weekend select Monday
    if (weekday > 4) {
      weekday = 0;
    }

    return weekday;
  }

  bool _dayIsOver(int weekday) {
    if (Data.timetable.days[weekday].units.isNotEmpty) {
      if (DateTime.now().isAfter(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        8,
      ).add(Duration(
          minutes: [60, 130, 210, 280, 360, 420, 480, 545][
              Data.timetable.days[weekday].getUserLessonsCount(
                      AppLocalizations.of(context).freeLesson) -
                  1])))) {
        return true;
      }
    }
    return false;
  }
}
