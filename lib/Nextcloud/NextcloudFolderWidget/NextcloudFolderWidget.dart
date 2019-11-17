import 'package:flutter/material.dart';
import '../NextcloudModel.dart' as cloud;
import 'NextcloudFolderWidgetView.dart';

class NextcloudFolderWidget extends StatefulWidget {
  final cloud.Element element;
  final Function() onTap;

  NextcloudFolderWidget({this.element, this.onTap});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderWidgetView();
  }
}


abstract class NextcloudFolderWidgetState extends State<NextcloudFolderWidget> {

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }
  
}