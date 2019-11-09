import 'package:flutter/material.dart';

import 'NewTimetableDialogView.dart';

class NewTimetableDialog extends StatefulWidget {
  NewTimetableDialog({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewTimetableDialogDialogView();
}

abstract class NewTimetableDialogState extends State<NewTimetableDialog> {
  @override
  void initState() {
    super.initState();
  }
}
