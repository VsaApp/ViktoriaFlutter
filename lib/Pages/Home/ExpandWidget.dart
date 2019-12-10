import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// A widget to show a expand list option
class ExpandWidget extends StatelessWidget {
  /// The button text
  final String text;

  /// Tab listener
  final void Function() onTab;

  // ignore: public_member_api_docs
  const ExpandWidget({@required this.text, this.onTab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              MdiIcons.menuDown,
              color: Colors.black54,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w100),
              ),
            )
          ],
        ),
      ),
    );
  }
}
