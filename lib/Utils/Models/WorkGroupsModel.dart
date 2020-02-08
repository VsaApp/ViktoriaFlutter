import 'package:flutter/material.dart';

/// Describes a list of work groups days...
class WorkGroups {
  /// All work groups day in the week
  List<WorkGroupsDay> days;

  // ignore: public_member_api_docs
  WorkGroups({@required this.days});
}

/// Describes a work group day...
class WorkGroupsDay {
  /// The index of the weekday (0 to 4)
  final int weekday;

  /// All work groups on this day
  final List<WorkGroup> data;

  // ignore: public_member_api_docs
  WorkGroupsDay({this.weekday, this.data});

  /// Creates a work group day from json map
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
  // ignore: public_member_api_docs
  final String name;
  // ignore: public_member_api_docs
  final String participants;
  // ignore: public_member_api_docs
  final String time;
  // ignore: public_member_api_docs
  final String place;

  // ignore: public_member_api_docs
  WorkGroup({this.name, this.participants, this.time, this.place});

  /// Creates a work group from json map
  factory WorkGroup.fromJson(Map<String, dynamic> json) {
    return WorkGroup(
        name: json['name'] as String,
        participants: json['participants'] as String,
        time: json['time'] as String,
        place: json['place'] as String);
  }
}
