import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

import 'package:viktoriaflutter/Cafetoria/DayCard/DayCardWidget.dart';
import 'package:viktoriaflutter/Calendar/EventCard/EventCard.dart';
import 'package:viktoriaflutter/SubstitutionPlan/SubstitutionPlanRow/SubstitutionPlanRowWidget.dart';
import 'package:viktoriaflutter/Timetable/TimetableRow/TimetableRowWidget.dart';
import 'package:viktoriaflutter/WorkGroups/DayCard/DayCardWidget.dart';

import 'IntroPage.dart';
import 'IntroSlider/IntroSliderWidget.dart';
import 'Slide/SlideWidget.dart';

class IntroPageView extends IntroPageState {
  void onFinished() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    slides.clear();
    TimetableSubject subject = TimetableSubject(
      unit: 2,
      teacherID: 'STA',
      subjectID: 'Erdkunde',
      roomID: '525',
      id: '',
      courseID: '',
      week: 2,
      block: '',
      day: 1
    );
    Substitution change = Substitution(
      unit: 1,
      id: null,
      courseID: null,
      info: '',
      type: 1,
      original: SubstitutionDetails(
        roomID: '233',
        teacherID: 'HIM',
        subjectID: 'Englisch'
      ),
      changed: SubstitutionDetails(
          subjectID: 'Deutsch',
          teacherID: '',
          roomID: ''
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context).introTimetableTitle,
        description: AppLocalizations.of(context).introTimetableDescription,
        backgroundColor: Theme.of(context).primaryColor,
        centerWidget: Container(
          margin: EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(children: [
                TimetableRow(
                  weekday: 0,
                  subject: subject,
                  unit: 0,
                  isDialog: !(Platform.isIOS || Platform.isAndroid),
                ),
                SubstitutionPlanRow(
                  substitution: change,
                  changes: [change],
                  weekday: 0,
                  isDialog: !(Platform.isIOS || Platform.isAndroid),
                )
              ]),
            ),
          ),
        ),
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context).introSubstitutionPlanTitle,
        description:
        AppLocalizations.of(context).introSubstitutionPlanDescription,
        centerWidget: Section(
          isLast: false,
          title: AppLocalizations.of(context).myChanges,
          children: [
            SubstitutionPlanRow(
              substitution: change,
              changes: [change],
              weekday: 0,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    if (Platform.isIOS || Platform.isAndroid) {
      slides.add(Slide(
        title: AppLocalizations
            .of(context)
            .introNotificationsTitle,
        description: AppLocalizations
            .of(context)
            .introNotificationsDescription,
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }
    CalendarEvent event = CalendarEvent(
      name: 'Elternsprechtag',
      info: '',
      start: DateTime(2019, 3, 12, 15),
      end: DateTime(2019, 3, 12, 19),
    );
    slides.add(Slide(
      title: AppLocalizations.of(context).introCalendarTitle,
      description: AppLocalizations.of(context).introCalendarDescription,
      centerWidget: Container(
        margin: EdgeInsets.all(10),
        child: EventCard(event: event),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    CafetoriaDay cafetoriaDay = CafetoriaDay(
      day: 0,
      date: '11.3.2019',
      menus: [
        CafetoriaMenu(
          name: 'Fleischbällchen mit Reis',
          time: '',
          price: 3.99,
        ),
        CafetoriaMenu(
          name: 'Süßkartoffel-Rosenkohlpfanne',
          time: '',
          price: 3.99,
        ),
        CafetoriaMenu(
          name: 'Beilagensalat Obst/Dessert',
          time: '',
          price: 0,
        ),
      ],
    );
    slides.add(Slide(
      title: AppLocalizations.of(context).introCafetoriaTitle,
      description: AppLocalizations.of(context).introCafetoriaDescription,
      centerWidget: Container(
        margin: EdgeInsets.all(10),
        child: CafetoriaDayCard(
          day: cafetoriaDay,
          showWeekday: true,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    ));

    WorkGroupsDay workGroupsDay = WorkGroupsDay(
      weekday: 0,
      data: [
        WorkGroup(
          name: 'Fußball',
          participants: '8 - 9',
          time: '14:00 - 15:00',
          place: 'grH',
        ),
        WorkGroup(
          name: 'Unterstufenchor',
          participants: '5 - 7',
          time: '14:45 - 15:45',
          place: '501',
        ),
        WorkGroup(
          name: 'Mittelstufenchor',
          participants: '8 - 9',
          time: '14:45 - 16:00',
          place: 'Aul',
        ),
        WorkGroup(
          name: 'Badminton AG',
          participants: 'alle',
          time: '18:30 - 20:00',
          place: 'grH',
        ),
      ],
    );
    slides.add(Slide(
      title: AppLocalizations.of(context).introWorkGroupsTitle,
      description: AppLocalizations.of(context).introWorkGroupsDescription,
      centerWidget: Container(
        margin: EdgeInsets.all(10),
        child: WorkGroupsDayCard(
          day: workGroupsDay,
          showWeekday: true,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    slides.add(Slide(
      title: AppLocalizations.of(context).introExtendedTimetableTitle,
      description:
      AppLocalizations.of(context).introExtendedTimetableDescription,
      backgroundColor: Theme.of(context).primaryColor,
    ));
    slides.add(Slide(
      title: AppLocalizations.of(context).introCoursesTitle,
      description: AppLocalizations.of(context).introCoursesDescription,
      backgroundColor: Theme.of(context).primaryColor,
    ));

    String grade = Storage.getString(Keys.grade);
    if ((grade == 'EF' || grade == 'Q1' || grade == 'Q2') &&
        (Platform.isIOS || Platform.isAndroid)) {
      slides.add(Slide(
        title: AppLocalizations
            .of(context)
            .introScannerTitle,
        description: AppLocalizations
            .of(context)
            .introScannerDescription,
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }

    slides.add(Slide(
      title: AppLocalizations.of(context).introVsaAppTitle,
      description: AppLocalizations.of(context).introVsaAppDescription,
      backgroundColor: Theme.of(context).primaryColor,
    ));

    return Scaffold(
      body: IntroSlider(
        slides: this.slides,
        onFinished: onFinished,
      ),
    );
  }
}
