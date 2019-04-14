import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Keys.dart';
import 'package:viktoriaflutter/Storage.dart';

class Notices {
  static List<Notice> notices = [];

  static void addNotice(Notice notice) {
    notices.add(notice);
    Storage.setString(Keys.notices,
        json.encode(notices.map((notice) => notice.toJSON()).toList()));
  }

  static void removeNotice(Notice notice) {
    notices.removeWhere((n) => n == notice);
    Storage.setString(Keys.notices,
        json.encode(notices.map((notice) => notice.toJSON()).toList()));
  }
}

class Notice {
  String title;
  String description;
  String image;
  String transcript;

  Notice({
    @required this.title,
    @required this.description,
    this.image,
    this.transcript,
  }) : super();

  factory Notice.fromJSON(Map<String, String> json) {
    return Notice(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      transcript: json['transcript'],
    );
  }

  String toJSON() {
    return json.encode({
      'title': title,
      'description': description,
      'image': image,
      'transcript': transcript,
    });
  }
}
