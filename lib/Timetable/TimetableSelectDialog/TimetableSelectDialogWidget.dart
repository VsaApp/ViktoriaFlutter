import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/Selection.dart';
import 'package:viktoriaflutter/Utils/Tags.dart';
import 'package:viktoriaflutter/Utils/Models.dart';
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

  /// The timetable [day]
  TimetableDay day;

  /// The timetable [unit]
  TimetableUnit unit;

  /// Selects a subject
  void optionSelected(TimetableSubject subject) {
    setSelectedSubject(subject);

    if (widget.enableWrapper) {
      Navigator.pop(context);
    }
    widget.onSelected();

    // Synchronize tags for notifications
    syncTags(syncExams: false, syncCafetoria: false);
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
