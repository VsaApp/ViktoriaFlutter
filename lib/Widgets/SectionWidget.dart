import 'package:flutter/material.dart';

/// Defines one substitution plan section
class Section extends StatelessWidget {
  // ignore: public_member_api_docs
  final List<Widget> children;
  // ignore: public_member_api_docs
  final String title;

  /// Set if it is the last section on page
  final bool isLast;
  // ignore: public_member_api_docs
  final double margin;
  // ignore: public_member_api_docs
  final double paddingTop;
  // ignore: public_member_api_docs
  final double paddingBottom;

  // ignore: public_member_api_docs
  const Section({
    @required this.children,
    @required this.title,
    this.margin = 10.0,
    this.paddingTop = 10.0,
    this.paddingBottom = 20.0,
    this.isLast = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(margin),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(title),
            ),
            Container(
                padding: EdgeInsets.only(
                    top: paddingTop, bottom: paddingBottom),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // List of items
                child: Column(
                  children: children,
                )),
          ],
        ),
      ),
    );
  }
}
