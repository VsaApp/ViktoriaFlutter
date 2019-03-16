import 'package:flutter/material.dart';

import '../Cafetoria/CafetoriaModel.dart';
import '../Cafetoria/DayCard/DayCardWidget.dart';
import '../Calendar/CalendarModel.dart';
import '../Calendar/EventCard/EventCard.dart';
import '../Keys.dart';
import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../SectionWidget.dart';
import '../UnitPlan/UnitPlanModel.dart';
import '../UnitPlan/UnitPlanRow/UnitPlanRowWidget.dart';
import '../WorkGroups/DayCard/DayCardWidget.dart';
import '../WorkGroups/WorkGroupsModel.dart';
import 'IntroPage.dart';
import 'IntroSlider/IntroSliderWidget.dart';
import 'Slide/SlideWidget.dart';

class IntroPageView extends IntroPageState {
  void onFinished() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (sharedPreferences == null) {
      return Container();
    }
    slides.clear();
    UnitPlanSubject subject = UnitPlanSubject(
      teacher: 'STA',
      lesson: 'Erdkunde',
      room: '525',
      block: '',
      course: '',
      changes: [],
      unsures: 0,
      week: 'AB',
    );
    Change change = Change(
        unit: 1,
        lesson: 'Deutsch',
        room: '516',
        course: '',
        teacher: 'KLU',
        changed: Changed(
            info: AppLocalizations.of(context).freeLesson,
            subject: 'Deutsch',
            teacher: '',
            room: ''),
        sure: true);
    slides.add(
      Slide(
        title: AppLocalizations.of(context).introUnitPlanTitle,
        description: AppLocalizations.of(context).introUnitPlanDescription,
        centerWidget: Container(
          margin: EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(children: [
                UnitPlanRow(
                  weekday: 0,
                  subject: subject,
                  unit: 0,
                  sharedPreferences: sharedPreferences,
                ),
                ReplacementPlanRow(
                  change: change,
                  changes: [change],
                  weekday: 0,
                  sharedPreferences: sharedPreferences,
                )
              ]),
            ),
          ),
        ),
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context).introReplacementPlanTitle,
        description:
            AppLocalizations.of(context).introReplacementPlanDescription,
        centerWidget: Section(
          isLast: false,
          title: AppLocalizations.of(context).myChanges,
          children: [
            ReplacementPlanRow(
              change: change,
              changes: [change],
              weekday: 0,
              sharedPreferences: sharedPreferences,
            ),
          ],
        ),
      ),
    );
    slides.add(Slide(
      title: AppLocalizations.of(context).introNotificationsTitle,
      description: AppLocalizations.of(context).introNotificationsDescription,
    ));
    CalendarEvent event = CalendarEvent(
      name: 'Elternsprechtag',
      info: '',
      start: CalendarEventDate(
        date: '12.3.2019',
        time: '15:00',
      ),
      end: CalendarEventDate(date: '12.3.2019', time: '19:00'),
    );
    slides.add(Slide(
      title: AppLocalizations.of(context).introCalendarTitle,
      description: AppLocalizations.of(context).introCalendarDescription,
      centerWidget: Container(
        margin: EdgeInsets.all(10),
        child: EventCard(event: event),
      ),
    ));
    CafetoriaDay cafetoriaDay = CafetoriaDay(
      weekday: 'Montag',
      date: '11.3.2019',
      menues: [
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
    ));

    WorkGroupsDay workGroupsDay = WorkGroupsDay(
      weekday: 'Montag',
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
    ));
    slides.add(Slide(
      title: AppLocalizations.of(context).introExtendedUnitplanTitle,
      description:
          AppLocalizations.of(context).introExtendedUnitplanDescription,
    ));
    slides.add(Slide(
      title: AppLocalizations.of(context).introCoursesTitle,
      description: AppLocalizations.of(context).introCoursesDescription,
    ));

    String grade = sharedPreferences.getString(Keys.grade);
    if (grade == 'EF' || grade == 'Q1' || grade == 'Q2') {
      slides.add(Slide(
        title: AppLocalizations
            .of(context)
            .introScannerTitle,
        description: AppLocalizations
            .of(context)
            .introScannerDescription,
      ));
    }

    slides.add(Slide(
      title: AppLocalizations.of(context).introVsaAppTitle,
      description: AppLocalizations.of(context).introVsaAppDescription,
    ));

    slides.forEach((slide) {
      slide.backgroundColor = Theme.of(context).primaryColor;
    });
    return Scaffold(
      body: IntroSlider(
        slides: this.slides,
        onFinished: onFinished,
      ),
    );
  }
}
