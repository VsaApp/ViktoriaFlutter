import 'package:flutter/material.dart';

import '../Keys.dart';
import '../Localizations.dart';
import '../Rooms/RoomsModel.dart';
import '../SectionWidget.dart';
import '../Selection.dart';
import '../Subjects/SubjectsModel.dart';
import '../Teachers/TeachersModel.dart';
import '../UnitPlan/UnitPlanModel.dart';
import '../UnitPlan/UnitPlanSelectDialog/UnitPlanSelectDialogWidget.dart';
import 'ScanPage.dart';

class ScanPageView extends ScanPageState {
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
      String _text = subject + ' ' + teacher + ' ' + room + '\n';
      print('m: ' + _text);
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
            if (subject == s.lesson && room == sRoom && teacher == sTeacher) {
              matchingSubjects.add(MatchingSubject(
                subject: s,
                weekday: UnitPlan.days.indexOf(day),
                unit: day.lessons.indexOf(lesson),
                index: lesson.subjects.indexOf(s),
              ));
            } else if (room == sRoom && teacher == sTeacher) {
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
          print(match.weekday.toString() +
              ' ' +
              match.unit.toString() +
              ' ' +
              match.index.toString());
          print(match.subject.lesson +
              ' ' +
              match.subject.teacher +
              ' ' +
              match.subject.room +
              ' ' +
              match.subject.course);
        });
        print('');
      } else {
        matchingSubjects.forEach((match) {
          setSelectedSubject(
              sharedPreferences, match.subject, match.weekday, match.unit);
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
    if (sharedPreferences == null || !scanCompleted) {
      return Container();
    }
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
    print(text);
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
          sharedPreferences.getString(Keys.grade),
          block: lesson.subjects[0].block,
          day: UnitPlan.days.indexOf(day),
          unit: day.lessons.indexOf(lesson),
        );
        if (!sharedPreferences.getKeys().contains(key)) {
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
        children: unidentifiedLessons.map((lesson) {
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
                  sharedPreferences: sharedPreferences,
                  onSelected: () => setState(() => null),
                  enableWrapper: false,
                ),
              ),
            ],
          );
        }).toList(),
      )
          : Container(
        alignment: Alignment(0.0, -1.0),
        padding: EdgeInsets.all(10.0),
        child: Text(AppLocalizations
            .of(context)
            .scanUnitPlanAllDetected),
      ),
    );

    /*return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).scanUnitPlan),
        elevation: 0.0,
      ),
      body: unidentifiedLessons.length > 0
          ? ListView(
              shrinkWrap: true,
              children: unidentifiedLessons.map((lesson) {
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
                  children: lesson.lesson.subjects.map((subject) {
                    return GestureDetector(
                      onTap: () {
                        setSelectedSubject(sharedPreferences, subject,
                                lesson.weekday, lesson.unit)
                            .then((_) => setState(() {}));
                      },
                      child: UnitPlanRow(
                        subject: subject,
                        weekday: 0,
                        unit: 0,
                        showUnit: false,
                        sharedPreferences: sharedPreferences,
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            )
          : Container(
              alignment: Alignment(0.0, -1.0),
              padding: EdgeInsets.all(10.0),
              child: Text(AppLocalizations.of(context).scanUnitPlanAllDetected),
            ),
    );*/
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
