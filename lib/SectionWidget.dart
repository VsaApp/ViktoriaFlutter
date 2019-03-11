import 'package:flutter/material.dart';

import 'SectionView.dart';

class Section extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final bool isLast;
  final double margin;
  final double paddingTop;
  final double paddingBottom;

  Section({
    Key key,
    @required this.children,
    @required this.title,
    this.margin = 10.0,
    this.paddingTop = 10.0,
    this.paddingBottom = 20.0,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SectionView();
  }
}
