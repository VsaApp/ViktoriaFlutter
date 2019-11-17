import 'package:flutter/material.dart';
import './NextcloudFolderPage/NextcloudFolderPage.dart';

class NextcloudPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return NextcloudFolderPage(name: 'Home', path: '/');
  }
}