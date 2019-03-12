import 'package:flutter/material.dart';

import '../Slide/SlideWidget.dart';

class IntroSlider extends StatefulWidget {
  final List<Slide> slides;
  final Function onFinished;

  IntroSlider({
    Key key,
    @required this.slides,
    @required this.onFinished,
  }) : super(key: key);

  @override
  IntroSliderState createState() => IntroSliderState();
}

class IntroSliderState extends State<IntroSlider> 
  with SingleTickerProviderStateMixin {
  int slideIndex = 0;
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: widget.slides.length);
    tabController.addListener(() => setState(() => null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TabBarView(
          controller: tabController,
          children: widget.slides,
        ),
        tabController.index == 0
            ? Align(
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
                    child: skip(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              )
            : Align(
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
                        tabController.animateTo(tabController.index--);
                      });
                    },
                    color: Theme.of(context).accentColor,
                    child: previous(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
        tabController.index  == widget.slides.length - 1
            ? Align(
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
                    child: done(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              )
            : Align(
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
                        tabController.animateTo(tabController.index + 1);
                      });
                    },
                    color: Theme.of(context).accentColor,
                    child: next(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget done() {
    return Icon(
      Icons.done,
      color: Color(0xffffffff),
    );
  }

  Widget next() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xffffffff),
    );
  }

  Widget previous() {
    return Icon(
      Icons.navigate_before,
      color: Color(0xffffffff),
    );
  }

  Widget skip() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffffffff),
    );
  }
}
