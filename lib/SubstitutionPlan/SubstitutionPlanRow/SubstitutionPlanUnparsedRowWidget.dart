import 'package:flutter/material.dart';

/// Widget to show an unparsed substitution
class SubstitutionPlanUnparsedRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanUnparsedRow({Key key, this.substitution})
      : super(key: key);

  /// The unparsed substitution string
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
