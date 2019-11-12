import 'package:flutter/material.dart';

class SubstitutionPlanUnparsedRow extends StatelessWidget {
  const SubstitutionPlanUnparsedRow({Key key, this.substitution})
      : super(key: key);

  final String substitution;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Text(substitution, style: TextStyle(color: Colors.green));
        },
      ),
    );
  }
}
