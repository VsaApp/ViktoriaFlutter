import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'package:viktoriaflutter/Nextcloud/NextcloudFolderPage/NextcloudFolderView.dart';
import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart' as cloud;
import 'package:viktoriaflutter/Nextcloud/NextcloudData.dart';

/// A page with a list of all directories and files of one parent directory
class NextcloudFolderPage extends StatefulWidget {
  /// The parent directory of the shown elements
  final cloud.Directory directory;

  // ignore: public_member_api_docs
  const NextcloudFolderPage({this.directory});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderPageView();
  }
}

// ignore: public_member_api_docs
abstract class NextcloudFolderPageState extends State<NextcloudFolderPage> {
  /// The parent directory
  cloud.Directory directory;
  void Function() _listener;

  @override
  void initState() {
    directory = widget.directory;
    _listener = directory.addListener(() {
      if (mounted) {
        setState(() => null);
      }
    });
    load();
    super.initState();
  }

  @override
  void dispose() {
    directory.removeListener(_listener);
    super.dispose();
  }

  /// Downloads and opens a file
  Future openFile(cloud.File file) async {
    // Download file content
    file = await Nextcloud.loadFile(file);

    // Get file path
    final String localPath = await _localPath;
    final String absoluteFilePath = '$localPath${Uri.decodeFull(file.path)}';

    // Create directory
    Directory(absoluteFilePath.replaceAll('/${file.name}', ''))
        .createSync(recursive: true);

    // Write and open file
    File(absoluteFilePath).writeAsBytes(file.content);
    await OpenFile.open(absoluteFilePath);
  }

  /// Reloads the element of a directory
  Future onReload() async {
    return Nextcloud.loadDirectory(directory);
  }

  /// Loads all elements of a directory
  void load() => onReload();

  /// Returns the local path to save files without permissions
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Upload a local file
  Future uploadFiles(cloud.Directory directory) async {
    final List<File> files = await FilePicker.getMultiFile();
    final List<cloud.File> cloudFiles = files.map((file) {
      final List<String> path = file.path.split('/');
      return cloud.File(
          name: path[path.length - 1],
          path: '${directory.path}${path[path.length - 1]}',
          modificationTime: file.lastModifiedSync(),
          shareTypes: [],
          content: file.readAsBytesSync(),
          isCreated: 1)
        ..loading = true;
    }).toList();
    directory.elements.insertAll(0, cloudFiles);
    directory.onUpdate(false);

    for (cloud.File file in cloudFiles) {
      await Nextcloud.uploadFile(file);
    }
  }
}
