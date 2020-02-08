import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';
import './NextcloudFolderPage/NextcloudFolderPage.dart';

/// A page to interact with the school nextcloud
class NextcloudPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Nextcloud.init();
    return NextcloudFolderPage(directory: Nextcloud.baseDir);
  }
}
