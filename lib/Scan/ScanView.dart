import 'dart:async';

import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';
import '../Rooms/RoomsModel.dart';
import 'package:viktoriaflutter/Utils/SectionWidget.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import '../Subjects/SubjectsModel.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import '../Teachers/TeachersModel.dart';
import '../UnitPlan/UnitPlanModel.dart';
import '../UnitPlan/UnitPlanSelectDialog/UnitPlanSelectDialogWidget.dart';
import 'ScanPage.dart';

class ScanPageView extends ScanPageState {
  bool show = true;
  String subjectsRegex = '(' +
      Subjects.subjects.keys
          .toList()
          .map((subject) => subject.toLowerCase())
          .join('|') +
      ')';
  String teachersRegex = '(' +
      Teachers.teachers
          .map((teacher) => teacher.shortName
          .toLowerCase()
          .replaceAll('ä', 'a')
          .replaceAll('ö', 'o')
          .replaceAll('ü', 'u'))
          .join('|') +
      ')';
  String roomRegex = '(' +
      Rooms.rooms.keys.toList().map((room) => room.toLowerCase()).join('|') +
      ')';

  insertData(List<String> matches) {
    matches.forEach((match) {
      String subject = '';
      try {
        subject = Subjects.subjects[RegExp(subjectsRegex)
            .firstMatch(match)
            .group(0)
            .toUpperCase()] ??
            RegExp(subjectsRegex).firstMatch(match).group(0);
      } catch (e) {}
      String teacher =
      RegExp(teachersRegex).firstMatch(match).group(0).toUpperCase();
      String room = Rooms.rooms[match.substring(
          match.indexOf(RegExp(teachersRegex).firstMatch(match).group(0)) +
              3)] ??
          match.substring(
              match.indexOf(RegExp(teachersRegex).firstMatch(match).group(0)) +
                  3);
      List<MatchingSubject> matchingSubjects = [];
      UnitPlan.days.forEach((day) {
        day.lessons.forEach((lesson) {
          lesson.subjects.forEach((s) {
            String sRoom = s.room.toUpperCase();
            String sTeacher = s.teacher
                .toUpperCase()
                .replaceAll('Ä', 'A')
                .replaceAll('Ö', 'O')
                .replaceAll('Ü', 'U');
            if ((subject == s.lesson && room == sRoom && teacher == sTeacher) ||
                (room == sRoom && teacher == sTeacher) ||
                (subject == s.lesson && teacher == sTeacher)) {
              matchingSubjects.add(MatchingSubject(
                subject: s,
                weekday: UnitPlan.days.indexOf(day),
                unit: day.lessons.indexOf(lesson),
                index: lesson.subjects.indexOf(s),
              ));
            }
          });
        });
      });
      if (matchingSubjects.length > 4 || matchingSubjects.length == 0) {
        matchingSubjects.forEach((match) {
          print('Unmatched subject: ' +
              match.subject.lesson +
              ' ' +
              match.subject.teacher +
              ' ' +
              match.subject.room);
        });
      } else {
        matchingSubjects.forEach((match) {
          setSelectedSubject(match.subject, match.weekday, match.unit);
        });
      }
    });
  }

  removeFoundMatches(String text, List<Match> matches) {
    createStringMatches(matches).forEach((match) {
      text = text.replaceAll(match, '');
    });
    return text;
  }

  createStringMatches(List<Match> matches) {
    return matches
        .map((match) {
      return match.group(0).replaceAll(RegExp('sp[0-9]\/'), 'sp/');
    })
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!scanCompleted || !show) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations
              .of(context)
              .scanUnitPlan),
          elevation: 0.0,
        ),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
        ),
      );
    }
    syncTags();
    String text = texts
        .map((text) => text.value)
        .toList()
        .join('')
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('/', '')
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');
    RegExp regExp =
    RegExp(subjectsRegex + '([0-9]).{0,2}' + teachersRegex + roomRegex);
    RegExp maybeRegExp = RegExp(teachersRegex + roomRegex);
    List<Match> matches = regExp.allMatches(text).toList();
    List<Match> maybeMatches = maybeRegExp.allMatches(text).toList();
    text = removeFoundMatches(text, matches);
    text = removeFoundMatches(text, maybeMatches);
    insertData(createStringMatches(matches));
    insertData(createStringMatches(maybeMatches));

    print('Unmatched text: ' + text);

    List<UnidentifiedLesson> unidentifiedLessonsT = [];
    List<UnidentifiedLesson> unidentifiedLessons = [];

    UnitPlan.days.forEach((day) {
      day.lessons.forEach((lesson) {
        String key = Keys.unitPlan(
          Storage.getString(Keys.grade),
          block: lesson.subjects[0].block,
          day: UnitPlan.days.indexOf(day),
          unit: day.lessons.indexOf(lesson),
        );
        if (!Storage.getKeys().contains(key)) {
          unidentifiedLessonsT.add(UnidentifiedLesson(
            lesson: lesson,
            weekday: UnitPlan.days.indexOf(day),
            unit: day.lessons.indexOf(lesson),
          ));
        }
      });
    });
    unidentifiedLessonsT.forEach((lesson) {
      if (lesson.lesson.subjects[0].block != '') {
        if (unidentifiedLessons
            .where((l) =>
        l.lesson.subjects[0].block ==
            lesson.lesson.subjects[0].block)
            .length >
            0) {
          return;
        }
      }
      unidentifiedLessons.add(lesson);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).scanUnitPlan),
        elevation: 0.0,
      ),
      body: unidentifiedLessons.length > 0
          ? ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              AppLocalizations
                  .of(context)
                  .scanDescription,
              textAlign: TextAlign.center,
            ),
          )
        ]
          ..addAll(unidentifiedLessons.map((lesson) {
            return Section(
              title: [
                'Montag',
                'Dienstag',
                'Mittwoch',
                'Donnerstag',
                'Freitag'
              ][lesson.weekday] +
                  ' ' +
                  (lesson.unit + 1).toString() +
                  '. Stunde' +
                  (lesson.lesson.subjects[0].block != ''
                      ? ' (' + lesson.lesson.subjects[0].block + ')'
                      : ''),
              children: <Widget>[
                Container(
                  child: UnitPlanSelectDialog(
                    day: UnitPlan.days[lesson.weekday],
                    lesson: lesson.lesson,
                    onSelected: () {
                      setState(() {
                        show = false;
                      });
                      Timer(Duration(milliseconds: 100), () {
                        setState(() {
                          show = true;
                        });
                      });
                    },
                    enableWrapper: false,
                  ),
                ),
              ],
            );
          }).toList()),
      )
          : Container(
        alignment: Alignment(0.0, -1.0),
        padding: EdgeInsets.all(10.0),
        child: Text(AppLocalizations
            .of(context)
            .scanUnitPlanAllDetected),
      ),
    );
  }
}

class MatchingSubject {
  final UnitPlanSubject subject;
  final int weekday;
  final int unit;
  final int index;

  MatchingSubject({this.subject, this.weekday, this.unit, this.index})
      : super();
}

class UnidentifiedLesson {
  final UnitPlanLesson lesson;
  final int weekday;
  final int unit;

  UnidentifiedLesson({this.lesson, this.weekday, this.unit}) : super();
}
