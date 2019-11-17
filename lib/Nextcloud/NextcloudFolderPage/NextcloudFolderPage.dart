import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'NextcloudFolderView.dart';
import '../NextcloudModel.dart' as cloud;
import '../NextcloudData.dart';

class NextcloudFolderPage extends StatefulWidget {
  final String name;
  final String path;

  NextcloudFolderPage({this.name, this.path});

  @override
  State<StatefulWidget> createState() {
    return NextcloudFolderPageView();
  }
}

abstract class NextcloudFolderPageState extends State<NextcloudFolderPage> {
  cloud.User user;
  cloud.Directory directory;

  @override
  void initState() {
    user = cloud.User(name: 'fingege', password: 'infonatik2');
    directory = cloud.Directory(name: widget.name, path: widget.path);
    load();
    super.initState();
  }

  Future openFile(cloud.File file) async {
    file = await loadFile(file, user.name, user.password);
    String fileEnd = file.name.split('.')[file.name.split('.').length - 1];
    String localPath = await _localPath;
    File localFile = await _localFile(fileEnd);
    localFile.writeAsString(file.content);
    String newContent = await OpenFile.open('$localPath/tmp.$fileEnd');
    print(newContent);
    file.content = newContent;
  }

  Future onReload() async {
    cloud.Directory dir = await loadDirectory(directory, user.name, user.password);
    setState(() => directory = dir);
  }

  void load() {
    loadDirectory(directory, user.name, user.password).then((cloud.Directory dir) {
      setState(() => directory = dir);
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(String type) async {
    final path = await _localPath;
    return File('$path/tmp.$type');
  }
}