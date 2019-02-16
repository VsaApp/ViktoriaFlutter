import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

import '../Localizations.dart';
import '../ReplacementPlan/ReplacementPlanModel.dart';
import '../ReplacementPlan/ReplacementPlanRow/ReplacementPlanRowWidget.dart';
import '../SectionWidget.dart';
import '../UnitPlan/UnitPlanModel.dart';
import '../UnitPlan/UnitPlanRow/UnitPlanRowWidget.dart';
import 'IntroPage.dart';

class IntroPageView extends IntroPageState {
  void onDonePress() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void onSkipPress() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xffffffff),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xffffffff),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffffffff),
    );
  }

  @override
  Widget build(BuildContext context) {
    slides.clear();
    UnitPlanSubject subject = UnitPlanSubject(
      teacher: 'KRA',
      lesson: 'EK',
      room: '525',
      block: '',
      course: '',
      changes: [],
      unsures: 0,
    );
    Change change = Change(
        unit: 0,
        lesson: 'EK',
        room: '525',
        course: '',
        teacher: 'KRA',
        changed: Changed(
            info: AppLocalizations.of(context).freeLesson,
            subject: 'EK',
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
                ),
                ReplacementPlanRow(change: change, changes: [change])
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
                ReplacementPlanRow(change: change, changes: [change])
              ])),
    );
    slides.forEach((slide) {
      slide.backgroundColor = Theme.of(context).primaryColor;
    });
    return IntroSlider(
      slides: this.slides,
      renderSkipBtn: this.renderSkipBtn(),
      onSkipPress: this.onSkipPress,
      colorSkipBtn: Theme.of(context).accentColor,
      highlightColorSkipBtn: Color(0xffffffff),
      onDonePress: this.onDonePress,
      renderNextBtn: this.renderNextBtn(),
      renderDoneBtn: this.renderDoneBtn(),
      colorDoneBtn: Theme.of(context).accentColor,
      highlightColorDoneBtn: Color(0xffffffff),
      colorDot: Color(0xffffffff),
      colorActiveDot: Theme.of(context).accentColor,
      sizeDot: 10.0,
    );
  }
}
