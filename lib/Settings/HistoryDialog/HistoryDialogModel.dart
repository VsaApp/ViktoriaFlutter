import 'package:flutter/material.dart';

// Describes a year of the histpry...
class Year {
  final String name;
  final List<Month> months;

  Year({
    @required this.name,
    @required this.months
  });

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      name: json['year'] as String,
      months: json['months'].map((i) => Month.fromJson(i)).toList().cast<Month>().toList(),
    );
  }
}

class Month {
  final String name;
  final List<Day> days;

  Month({
    @required this.name,
    @required this.days
  });

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      name: json['month'] as String,
      days: json['days'].map((i) => Day.fromJson(i)).toList().cast<Day>().toList(),
    );
  }
}

class Day {
  final String name;
  final List<File> files;
  final List<Time> times;

  Day({
    @required this.name,
    @required this.files,
    @required this.times
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      name: json['day'] as String,
      files: json['htmls'].map((i) => File.fromJson(i)).toList().cast<File>().toList(),
      times: json['times'].map((i) => Time.fromJson(i)).toList().cast<Time>().toList(),
    );
  }
}

class Time {
  final String time;

  Time({this.time});

  factory Time.fromJson(String json) {
    return Time(
      time: json
    );
  }
}

class File {
  final String name;

  File({this.name});

  factory File.fromJson(String json) {
    return File(
      name: json
    );
  }
}