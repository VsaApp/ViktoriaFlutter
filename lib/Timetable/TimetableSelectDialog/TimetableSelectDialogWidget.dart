import 'package:flutter/material.dart';

import '../../SubstitutionPlan/SubstitutionPlanData.dart' as SubstitutionPlan;
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import '../TimetableModel.dart';
import 'TimetableSelectDialogView.dart';

class TimetableSelectDialog extends StatefulWidget {
  final TimetableDay day;
  final TimetableLesson lesson;
  final Function() onSelected;
  final bool enableWrapper;

  TimetableSelectDialog({
    Key key,
    @required this.day,
    @required this.lesson,
    @required this.onSelected,
    this.enableWrapper = true,
  }) : super(key: key);

  @override
  TimetableSelectDialogView createState() => TimetableSelectDialogView();
}

abstract class TimetableSelectDialogState extends State<TimetableSelectDialog>
    with SingleTickerProviderStateMixin {
  TimetableSubject lastSelected;

  bool hideABSubjects = false;
  bool hideBSubjects = false;
  bool hideASubjects = false;

  TimetableDay day;
  TimetableLesson lesson;

  List<TimetableSubject> getABSubjects() {
    return hideABSubjects
        ? []
        : lesson.subjects
        .where((TimetableSubject subject) => subject.week == 'AB')
        .toList();
  }

  List<TimetableSubject> getBSubjects() {
    return hideBSubjects
        ? []
        : lesson.subjects
        .where((TimetableSubject subject) => subject.week == 'B')
        .toList();
  }

  List<TimetableSubject> getASubjects() {
    return hideASubjects
        ? []
        : lesson.subjects
        .where((TimetableSubject subject) => subject.week == 'A')
        .toList();
  }

  TimetableSubject isOnlyRoomDiffrent(TimetableSubject subject) {
    if (subject.teacher == '') return null;
    List<TimetableSubject> possibleSubject = (subject.week == 'A'
        ? getBSubjects()
        : getASubjects())
        .where(
            (s) => s.lesson == subject.lesson && s.teacher == subject.teacher)
        .toList();
    if (possibleSubject.length == 1) return possibleSubject[0];
    return null;
  }

  void optionSelected(TimetableSubject subject) {
    if (subject.week == 'AB') {
      setSelectedSubject(
          subject, Timetable.days.indexOf(day), day.lessons.indexOf(lesson));
    } else {
      // Hide some sections of the list...
      setState(() => hideABSubjects = true);
      if (subject.week == 'B')
        setState(() => hideBSubjects = true);
      else
        setState(() => hideASubjects = true);

      if (lastSelected != null) {
        setSelectedSubject((subject.week == 'A' ? subject : lastSelected),
            Timetable.days.indexOf(day), day.lessons.indexOf(lesson),
            selectedB: (subject.week == 'A' ? lastSelected : subject));
      }
      // When only one other option is possible...
      else if ((subject.week == 'A' ? getBSubjects() : getASubjects()).length ==
          1) {
        setSelectedSubject((subject.week == 'A' ? subject : getASubjects()[0]),
            Timetable.days.indexOf(day), day.lessons.indexOf(lesson),
            selectedB: (subject.week == 'A' ? getBSubjects()[0] : subject));
      }
      // When there is the same lesson and only the room is diffrent...
      else if (isOnlyRoomDiffrent(subject) != null) {
        setSelectedSubject(
            (subject.week == 'A' ? subject : isOnlyRoomDiffrent(subject)),
            Timetable.days.indexOf(day),
            day.lessons.indexOf(lesson),
            selectedB:
            (subject.week == 'A' ? isOnlyRoomDiffrent(subject) : subject));
      } else {
        lastSelected = subject;
        return;
      }
    }

    if (widget.enableWrapper) Navigator.pop(context);
    widget.onSelected();

    // Synchronise tags for notifications
    syncTags();
    SubstitutionPlan.load(Timetable.days, false);
  }

  @override
  void initState() {
    day = widget.day;
    lesson = widget.lesson;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
