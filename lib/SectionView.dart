import 'package:flutter/material.dart';
import 'SectionWidget.dart';

class SectionView extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(widget.title),
            ),
            Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
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
