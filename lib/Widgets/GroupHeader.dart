import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// A header for a GroupList group
class GroupHeader extends StatelessWidget implements PreferredSizeWidget {
  /// The header title
  final String title;

  /// The count of the subelement of the header
  final int count;

  /// The title alignment
  final Alignment alignment;

  // ignore: public_member_api_docs
  const GroupHeader({@required this.title, @required this.count, this.alignment = Alignment.bottomCenter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      alignment: alignment,
      padding: EdgeInsets.only(bottom: 8, left: 10, right: 10),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: alignment,
            child: Text(
              title,
              style: TextStyle(
                  color: Color.fromARGB(255, 100, 100, 100),
                  fontSize: 20,
                  fontWeight: FontWeight.w100),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 10,
            child: Row(children: <Widget>[
              Icon(
                MdiIcons.plus,
                color: Theme.of(context).primaryColor,
                size: 12,
              ),
              Text(
                count.toString(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 12),
              )
            ]),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
