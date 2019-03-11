import 'package:flutter/material.dart';

class Slide extends StatelessWidget {
  String title;
  String description;
  Widget centerWidget;
  Color backgroundColor;

  Slide({
    Key key,
    @required this.title,
    this.description,
    @required this.centerWidget,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          child: Container(color: backgroundColor),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          margin: EdgeInsets.only(top: 24, bottom: 48),
          child: Column(
            children: <Widget>[
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
              centerWidget,
            ],
          ),
        ),
      ],
    );
  }
}
