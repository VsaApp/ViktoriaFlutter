import 'package:flutter/material.dart';
import 'SectionView.dart';

class Section extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final bool isLast;

  Section({Key key, this.children, this.title, this.isLast = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SectionView();
  }
}
