import 'package:flutter/material.dart';

import 'NewTimetableDialogView.dart';

/// Dialog to inform the user about a new timetable
class NewTimetableDialog extends StatefulWidget {
  // ignore: public_member_api_docs
  const NewTimetableDialog({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewTimetableDialogDialogView();
}

// ignore: public_member_api_docs
abstract class NewTimetableDialogState extends State<NewTimetableDialog> {
  @override
  void initState() {
    super.initState();
  }
}
