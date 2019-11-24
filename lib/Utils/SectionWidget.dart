import 'package:flutter/material.dart';

import 'package:viktoriaflutter/Utils/SectionView.dart';

/// Defines one substitution plan section
class Section extends StatefulWidget {
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
  State<StatefulWidget> createState() {
    return SectionView();
  }
}
