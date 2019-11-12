import 'package:flutter/material.dart';

/// Describes a list of work groups days...
class WorkGroups {
  List<WorkGroupsDay> days;

  WorkGroups({@required this.days});
}

/// Describes a work group day...
class WorkGroupsDay {
  final int weekday;
  final List<WorkGroup> data;

  WorkGroupsDay({this.weekday, this.data});

  factory WorkGroupsDay.fromJson(Map<String, dynamic> json) {
    return WorkGroupsDay(
      weekday: json['weekday'] as int,
      data: json['data']
          .map((i) => WorkGroup.fromJson(i))
          .toList()
          .cast<WorkGroup>(),
    );
  }
}

/// Describes a work group of a day...
class WorkGroup {
  final String name;
  final String participants;
  final String time;
  final String place;

  WorkGroup({this.name, this.participants, this.time, this.place});

  factory WorkGroup.fromJson(Map<String, dynamic> json) {
    return WorkGroup(
        name: json['name'] as String,
        participants: json['participants'] as String,
        time: json['time'] as String,
        place: json['place'] as String);
  }
}
