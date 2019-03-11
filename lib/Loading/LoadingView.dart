import 'package:flutter/material.dart';

import 'LoadingPage.dart';

class LoadingPageView extends LoadingPageState {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    List<Widget> items = texts.map((text) => Text(text)).toList();
    List<int> itemCharacters = texts.map((text) => text.length).toList();
    itemCharacters.sort((a, b) => b.compareTo(a));
    if (allDownloadsCount == 0) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  top: height -
                      ((allDownloadsCount - (allDownloadsCount > 0 ? 1 : 0)) *
                              16)
                          .toDouble() -
                      100 -
                      height / 5),
              child: SizedBox(
                child: CircularProgressIndicator(strokeWidth: 5.0),
                height: 75.0,
                width: 75.0,
              ),
            ),
          ),
          itemCharacters.length > 0
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: height -
                          ((allDownloadsCount - 1) * 16).toDouble() -
                          height / 5,
                    ),
                    child: SizedBox(
                      height: ((texts.length + 1) * 16).toDouble(),
                      width: (itemCharacters[0] * 7).toDouble(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
