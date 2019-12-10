import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Models/Models.dart';
import 'TimetableSelectDialogOptionView.dart';

/// One subject in the timetable select dialog
class TimetableSelectDialogOption extends StatefulWidget {
  /// The subject option
  final TimetableSubject subject;

  /// The timetable unit
  final TimetableUnit unit;

  /// The on select listener
  final Function(TimetableSubject subject) onSelected;

  // ignore: public_member_api_docs
  const TimetableSelectDialogOption({
    Key key,
    this.subject,
    this.onSelected,
    this.unit,
  }) : super(key: key);

  @override
  TimetableSelectDialogOptionView createState() =>
      TimetableSelectDialogOptionView();
}

// ignore: public_member_api_docs
abstract class TimetableSelectDialogOptionState
    extends State<TimetableSelectDialogOption>
    with SingleTickerProviderStateMixin {
  /// The [unit] of the current [subject]
  TimetableUnit unit;

  /// Timetable subject (This option)
  TimetableSubject subject;

  @override
  void initState() {
    unit = widget.unit;
    subject = widget.subject;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
