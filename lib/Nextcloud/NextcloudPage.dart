import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import './NextcloudFolderPage/NextcloudFolderPage.dart';

class NextcloudPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Nextcloud.init();
    return NextcloudFolderPage(directory: Nextcloud.baseDir);
  }
}
