import 'package:flutter/material.dart';

import '../Slide/SlideWidget.dart';

/// Sliding page with next, skip and finish buttons
class IntroSlider extends StatefulWidget {
  /// All slides
  final List<Slide> slides;

  /// On finished callback
  final Function onFinished;

  // ignore: public_member_api_docs
  const IntroSlider({
    @required this.slides,
    @required this.onFinished,
    Key key,
  }) : super(key: key);

  @override
  IntroSliderState createState() => IntroSliderState();
}

// ignore: public_member_api_docs
class IntroSliderState extends State<IntroSlider>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: widget.slides.length)
      ..addListener(() => setState(() => null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TabBarView(
          controller: _tabController,
          children: widget.slides,
        ),
        if (_tabController.index == 0)
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(
                left: 14,
                bottom: 8,
                right: 14,
              ),
              child: FlatButton(
                onPressed: () {
                  widget.onFinished();
                },
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.skip_next,
                  color: Color(0xffffffff),
                ),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(
                left: 14,
                bottom: 8,
                right: 14,
              ),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    _tabController.animateTo(_tabController.index--);
                  });
                },
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.navigate_before,
                  color: Color(0xffffffff),
                ),
              ),
            ),
          ),
        if (_tabController.index == widget.slides.length - 1)
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(
                left: 14,
                bottom: 8,
                right: 14,
              ),
              child: FlatButton(
                onPressed: () {
                  widget.onFinished();
                },
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.done,
                  color: Color(0xffffffff),
                ),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(
                left: 14,
                bottom: 8,
                right: 14,
              ),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    _tabController.animateTo(_tabController.index + 1);
                  });
                },
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.navigate_next,
                  color: Color(0xffffffff),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
