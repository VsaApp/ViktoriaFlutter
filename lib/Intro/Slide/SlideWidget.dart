import 'package:flutter/material.dart';

class Slide extends StatelessWidget {
  final String title;
  final String description;
  final Widget centerWidget;
  final Color backgroundColor;

  Slide({
    Key key,
    @required this.title,
    @required this.description,
    this.centerWidget,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
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
          child: Container(color: backgroundColor),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
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
