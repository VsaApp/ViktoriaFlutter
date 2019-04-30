import 'package:flutter/material.dart';

import '../../ReplacementPlan/ReplacementPlanData.dart' as Replacementplan;
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import '../UnitPlanModel.dart';
import 'UnitPlanSelectDialogView.dart';

class UnitPlanSelectDialog extends StatefulWidget {
  final UnitPlanDay day;
  final UnitPlanLesson lesson;
  final Function() onSelected;
  final bool enableWrapper;

  UnitPlanSelectDialog({
    Key key,
    @required this.day,
    @required this.lesson,
    @required this.onSelected,
    this.enableWrapper = true,
  }) : super(key: key);

  @override
  UnitPlanSelectDialogView createState() => UnitPlanSelectDialogView();
}

abstract class UnitPlanSelectDialogState extends State<UnitPlanSelectDialog>
    with SingleTickerProviderStateMixin {
  UnitPlanSubject lastSelected;

  bool hideABSubjects = false;
  bool hideBSubjects = false;
  bool hideASubjects = false;

  UnitPlanDay day;
  UnitPlanLesson lesson;

  List<UnitPlanSubject> getABSubjects() {
    return hideABSubjects
        ? []
        : lesson.subjects
        .where((UnitPlanSubject subject) => subject.week == 'AB')
        .toList();
  }

  List<UnitPlanSubject> getBSubjects() {
    return hideBSubjects
        ? []
        : lesson.subjects
        .where((UnitPlanSubject subject) => subject.week == 'B')
        .toList();
  }

  List<UnitPlanSubject> getASubjects() {
    return hideASubjects
        ? []
        : lesson.subjects
        .where((UnitPlanSubject subject) => subject.week == 'A')
        .toList();
  }

  UnitPlanSubject isOnlyRoomDiffrent(UnitPlanSubject subject) {
    if (subject.teacher == '') return null;
    List<UnitPlanSubject> possibleSubject = (subject.week == 'A'
        ? getBSubjects()
        : getASubjects())
        .where(
            (s) => s.lesson == subject.lesson && s.teacher == subject.teacher)
        .toList();
    if (possibleSubject.length == 1) return possibleSubject[0];
    return null;
  }

  void optionSelected(UnitPlanSubject subject) {
    if (subject.week == 'AB') {
      setSelectedSubject(
          subject, UnitPlan.days.indexOf(day), day.lessons.indexOf(lesson));
    } else {
      // Hide some sections of the list...
      setState(() => hideABSubjects = true);
      if (subject.week == 'B')
        setState(() => hideBSubjects = true);
      else
        setState(() => hideASubjects = true);

      if (lastSelected != null) {
        setSelectedSubject((subject.week == 'A' ? subject : lastSelected),
            UnitPlan.days.indexOf(day), day.lessons.indexOf(lesson),
            selectedB: (subject.week == 'A' ? lastSelected : subject));
      }
      // When only one other option is possible...
      else if ((subject.week == 'A' ? getBSubjects() : getASubjects()).length ==
          1) {
        setSelectedSubject((subject.week == 'A' ? subject : getASubjects()[0]),
            UnitPlan.days.indexOf(day), day.lessons.indexOf(lesson),
            selectedB: (subject.week == 'A' ? getBSubjects()[0] : subject));
      }
      // When there is the same lesson and only the room is diffrent...
      else if (isOnlyRoomDiffrent(subject) != null) {
        setSelectedSubject(
            (subject.week == 'A' ? subject : isOnlyRoomDiffrent(subject)),
            UnitPlan.days.indexOf(day),
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
    Replacementplan.load(UnitPlan.days, false);
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
