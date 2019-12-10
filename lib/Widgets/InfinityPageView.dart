import 'package:flutter/material.dart';

/// A page view like the flutter PageView, but with infinity scroll and a fixed height
class InfinityPage extends StatefulWidget {
  /// Controller for the page view
  final PageController controller;

  /// All pages
  final List<Widget> pages;

  // ignore: public_member_api_docs
  const InfinityPage({@required this.controller, @required this.pages, key})
      : super(key: key);

  @override
  InfinityPageState createState() => InfinityPageState();
}

// ignore: public_member_api_docs
class InfinityPageState extends State<InfinityPage> {

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Container(
          color: Colors.green,
          key: ValueKey<int>(index % widget.pages.length),
          child: widget.pages[index % widget.pages.length],
        );
      },
      controller: widget.controller,
    );
  }
}
