import 'package:flutter/material.dart';

/// A page with one feature
class Slide extends StatelessWidget {
  /// Feature name
  final String title;

  /// Feature description
  final String description;

  /// Feature example widget
  final Widget centerWidget;

  /// Background color of slide
  final Color backgroundColor;

  // ignore: public_member_api_docs
  const Slide({
    @required this.title,
    @required this.description,
    this.centerWidget,
    this.backgroundColor = Colors.blue,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.all(20),
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      centerWidget ?? Container(),
    ];
    return Stack(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(color: backgroundColor),
        ),
        Container(
          margin: EdgeInsets.only(top: 24, bottom: 48),
          child: centerWidget == null
              ? Center(
                  child: SizedBox(
                    height: 200,
                    child: Column(
                      children: items,
                    ),
                  ),
                )
              : Column(
                  children: items,
                ),
        ),
      ],
    );
  }
}
