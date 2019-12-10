import 'package:flutter/material.dart';

/// Describes all infos for a subject row
class SubjectRowDetails {
  // ignore: public_member_api_docs
  final String title;
  // ignore: public_member_api_docs
  final String subtitle;
  // ignore: public_member_api_docs
  final int unit;
  // ignore: public_member_api_docs
  final String infoLeftTop;
  // ignore: public_member_api_docs
  final String infoRightTop;
  // ignore: public_member_api_docs
  final String infoLeftBottom;
  // ignore: public_member_api_docs
  final String infoRightBottom;

  // ignore: public_member_api_docs
  SubjectRowDetails({
    @required this.title,
    @required this.subtitle,
    @required this.unit,
    this.infoLeftTop,
    this.infoRightTop,
    this.infoLeftBottom,
    this.infoRightBottom,
  });
}
