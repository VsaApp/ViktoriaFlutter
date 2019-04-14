import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Notices/NoticesModel.dart';

class NoticeWidget extends StatelessWidget {
  final Notice notice;
  final bool showExtended;

  NoticeWidget({
    Key key,
    @required this.notice,
    this.showExtended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String shortDescription = notice.description.substring(
          0,
          notice.description.length < 100 ? notice.description.length : 100,
        ) +
        (notice.description.length > 100 ? '...' : '');
    return Card(
      child: ListTile(
        leading: !showExtended
            ? Icon(
                notice.image != null ? Icons.image : Icons.text_fields,
                color: Theme.of(context).accentColor,
              )
            : null,
        title: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(notice.title),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              showExtended ? notice.description : shortDescription,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            showExtended && notice.image != null
                ? Container(
                    margin: EdgeInsets.all(5),
                    child: Image.memory(
                      base64Decode(notice.image),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
