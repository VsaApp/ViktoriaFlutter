import 'package:flutter/material.dart';

import 'SectionView.dart';

class Section extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final bool isLast;

  Section({
    Key key,
    @required this.children,
    @required this.title,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SectionView();
  }
}
