import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/SectionWidget.dart';

/// Card for one substitution plan section (for example: my changes)
class SectionView extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.margin),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(widget.title),
            ),
            Container(
                padding: EdgeInsets.only(top: widget.paddingTop, bottom: widget.paddingBottom),
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
                  children: widget.children,
                )),
          ],
        ),
      ),
    );
  }
}
