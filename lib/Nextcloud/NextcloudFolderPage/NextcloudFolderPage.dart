import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'NextcloudFolderView.dart';
import '../NextcloudModel.dart' as cloud;
import '../NextcloudData.dart';

class NextcloudFolderPage extends StatefulWidget {
  final cloud.Directory directory;

  NextcloudFolderPage({this.directory});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderPageView();
  }
}

abstract class NextcloudFolderPageState extends State<NextcloudFolderPage> {
  cloud.Directory directory;
  void Function() _listener;

  @override
  void initState() {
    directory = widget.directory;
    _listener = directory.addListener(() {
      if (mounted) setState(() => null);
    });
    load();
    super.initState();
  }

  @override
  void dispose() {
    directory.removeListener(_listener);
    super.dispose();
  }

  Future openFile(cloud.File file) async {
    // Download file content
    file = await Nextcloud.loadFile(file);

    // Get file path
    String localPath = await _localPath;
    String absoluteFilePath = '$localPath${Uri.decodeFull(file.path)}';

    // Create directory
    Directory(absoluteFilePath.replaceAll('/${file.name}', ''))
        .createSync(recursive: true);

    // Write and open file
    File(absoluteFilePath).writeAsBytes(file.content);
    await OpenFile.open(absoluteFilePath);
  }

  Future onReload() async {
    return Nextcloud.loadDirectory(directory);
  }

  void load() {
    Nextcloud.loadDirectory(directory);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future uploadFiles(cloud.Directory directory) async {
    List<File> files = await FilePicker.getMultiFile();
    List<cloud.File> cloudFiles = files.map((file) {
      List<String> path = file.path.split('/');
      final cloudFile = cloud.File(
          name: path[path.length - 1],
          path: '${directory.path}${path[path.length - 1]}',
          modificationTime: file.lastModifiedSync(),
          shareTypes: [],
          content: file.readAsBytesSync(),
          isCreated: 1);
      cloudFile.loading = true;
      return cloudFile;
    }).toList();
    directory.elements.insertAll(0, cloudFiles);
    directory.onUpdate(false);

    for (cloud.File file in cloudFiles) {
      await Nextcloud.uploadFile(file);
    }
  }
}
