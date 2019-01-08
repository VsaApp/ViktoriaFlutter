import 'package:flutter/material.dart';
import '../CafetoriaModel.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({Key key, this.menu}) : super(key: key);

  final CafetoriaMenu menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Menu name
                        Container(
                          width: constraints.maxWidth * 0.80,
                          child: Text(
                            (menu.name.length > 1)
                                ? menu.name[0].toUpperCase() +
                                    menu.name.substring(1)
                                : menu.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Menu time
                        (menu.time.length > 0)
                            ? Container(
                                width: constraints.maxWidth * 0.80,
                                child: Text(
                                  menu.time,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ))
                            : Container(),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        // Menu price
                        Container(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.03),
                          width: constraints.maxWidth * 0.17,
                          child: Text(
                            '${menu.price}€',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

