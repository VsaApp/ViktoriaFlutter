import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Models/Models.dart';
import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';

import 'TimetableSelectDialogView.dart';

/// Dialog to select a timetable subject
class TimetableSelectDialog extends StatefulWidget {
  /// The timetable [day]
  final TimetableDay day;

  /// The timetable [unit]
  final TimetableUnit unit;

  /// The selected listener
  final Function() onSelected;

  /// Defines if it is a dialog or not
  final bool enableWrapper;

  // ignore: public_member_api_docs
  const TimetableSelectDialog({
    @required this.day,
    @required this.unit,
    @required this.onSelected,
    this.enableWrapper = true,
    Key key,
  }) : super(key: key);

  @override
  TimetableSelectDialogView createState() => TimetableSelectDialogView();
}

// ignore: public_member_api_docs
abstract class TimetableSelectDialogState extends State<TimetableSelectDialog>
    with SingleTickerProviderStateMixin {
  TimetableSubject _lastSelected;

  bool _hideABSubjects = false;
  bool _hideBSubjects = false;
  bool _hideASubjects = false;

  /// The timetable [day]
  TimetableDay day;

  /// The timetable [unit]
  TimetableUnit unit;

  /// Get all subjects for both weeks
  List<TimetableSubject> getABSubjects() {
    return _hideABSubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 2)
            .toList();
  }

  /// Get all subjects for week B
  List<TimetableSubject> getBSubjects() {
    return _hideBSubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 1)
            .toList();
  }

  /// Get all subjects for week A
  List<TimetableSubject> getASubjects() {
    return _hideASubjects
        ? []
        : unit.subjects
            .where((TimetableSubject subject) => subject.week == 0)
            .toList();
  }

  /// Checks if only the room different
  TimetableSubject isOnlyRoomDifferent(TimetableSubject subject) {
    if (subject.teacherID == '') {
      return null;
    }
    final List<TimetableSubject> possibleSubject =
        (subject.week == 0 ? getBSubjects() : getASubjects())
            .where((s) =>
                s.subjectID == subject.subjectID &&
                s.teacherID == subject.teacherID)
            .toList();
    if (possibleSubject.length == 1) {
      return possibleSubject[0];
    }
    return null;
  }

  /// Selects a subject
  void optionSelected(TimetableSubject subject) {
    if (subject.week == 2) {
      setSelectedSubject(subject);
    } else {
      // Hide some sections of the list...
      setState(() => _hideABSubjects = true);
      if (subject.week == 1) {
        setState(() => _hideBSubjects = true);
      } else {
        setState(() => _hideASubjects = true);
      }

      if (_lastSelected != null) {
        setSelectedSubject(
          subject.week == 0 ? subject : _lastSelected,
          selectedB: subject.week == 0 ? _lastSelected : subject,
        );
      }
      // When only one other option is possible...
      else if ((subject.week == 0 ? getBSubjects() : getASubjects()).length ==
          1) {
        setSelectedSubject(
          subject.week == 0 ? subject : getASubjects()[0],
          selectedB: subject.week == 0 ? getBSubjects()[0] : subject,
        );
      }
      // When there is the same lesson and only the room is Different...
      else if (isOnlyRoomDifferent(subject) != null) {
        setSelectedSubject(
          subject.week == 0 ? subject : isOnlyRoomDifferent(subject),
          selectedB:
              subject.week == 0 ? isOnlyRoomDifferent(subject) : subject,
        );
      } else {
        _lastSelected = subject;
        return;
      }
    }

    if (widget.enableWrapper) {
      Navigator.pop(context);
    }
    widget.onSelected();

    // Synchronize tags for notifications
    syncTags(syncExams: false);
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
