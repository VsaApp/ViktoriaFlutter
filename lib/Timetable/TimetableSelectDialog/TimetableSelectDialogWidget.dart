import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
import 'TimetableSelectDialogView.dart';

class TimetableSelectDialog extends StatefulWidget {
  final TimetableDay day;
  final TimetableUnit unit;
  final Function() onSelected;
  final bool enableWrapper;

  TimetableSelectDialog({
    Key key,
    @required this.day,
    @required this.unit,
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
  TimetableUnit unit;

  List<TimetableSubject> getABSubjects() {
    return hideABSubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 2)
            .toList();
  }

  List<TimetableSubject> getBSubjects() {
    return hideBSubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 1)
            .toList();
  }

  List<TimetableSubject> getASubjects() {
    return hideASubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 0)
            .toList();
  }

  TimetableSubject isOnlyRoomDifferent(TimetableSubject subject) {
    if (subject.teacherID == '') return null;
    List<TimetableSubject> possibleSubject =
        (subject.week == 0 ? getBSubjects() : getASubjects())
            .where((s) =>
                s.subjectID == subject.subjectID &&
                s.teacherID == subject.teacherID)
            .toList();
    if (possibleSubject.length == 1) return possibleSubject[0];
    return null;
  }

  void optionSelected(TimetableSubject subject) {
    if (subject.week == 2) {
      setSelectedSubject(subject);
    } else {
      // Hide some sections of the list...
      setState(() => hideABSubjects = true);
      if (subject.week == 1)
        setState(() => hideBSubjects = true);
      else
        setState(() => hideASubjects = true);

      if (lastSelected != null) {
        setSelectedSubject(
          (subject.week == 0 ? subject : lastSelected),
          selectedB: (subject.week == 0 ? lastSelected : subject),
        );
      }
      // When only one other option is possible...
      else if ((subject.week == 0 ? getBSubjects() : getASubjects()).length ==
          1) {
        setSelectedSubject(
          (subject.week == 0 ? subject : getASubjects()[0]),
          selectedB: (subject.week == 0 ? getBSubjects()[0] : subject),
        );
      }
      // When there is the same lesson and only the room is Different...
      else if (isOnlyRoomDifferent(subject) != null) {
        setSelectedSubject(
          (subject.week == 0 ? subject : isOnlyRoomDifferent(subject)),
          selectedB:
              (subject.week == 0 ? isOnlyRoomDifferent(subject) : subject),
        );
      } else {
        lastSelected = subject;
        return;
      }
    }

    if (widget.enableWrapper) Navigator.pop(context);
    widget.onSelected();

    // Synchronize tags for notifications
    syncTags();
    Data.substitutionPlan.updateFilter();
  }

  @override
  void initState() {
    day = widget.day;
    unit = widget.unit;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
