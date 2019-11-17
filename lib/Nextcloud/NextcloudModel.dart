import 'package:webdav/webdav.dart';
import 'package:flutter/semantics.dart';
import 'NextcloudData.dart';

class Nextcloud {
  static User user;
  static Element dir;
}

class User {
  String name;
  String password;

  User({this.name, this.password});
}

class Element {
  String name;
  String path;
  String modificationTime;
  DateTime creationTime;

  Element({this.name, this.path, this.modificationTime, this.creationTime});

  isDirectory() => null;

  load() {
    
  }
}

class Directory extends Element {
  List<Element> elements;

  Directory({name, path, modificationTime, creationTime, this.elements}) {
    super.name = name;
    super.path = path;
    super.modificationTime = modificationTime;
    super.creationTime = creationTime;
  }

  factory Directory.fromFileInfo(FileInfo fileInfo) {
    return Directory(
      name: fileInfo.name,
      path: fileInfo.path,
      modificationTime: fileInfo.modificationTime,
      creationTime: fileInfo.creationTime
    );
  }

  @override
  isDirectory() {
    return true;
  }

  List<File> getFiles() {
    return elements.where((element) => !element.isDirectory()).toList().cast<File>();
  }

  List<Directory> getDirectories() {
    return elements.where((element) => element.isDirectory()).toList().cast<Directory>();
  }
}

class File extends Element {
  String content;

  File({name, path, modificationTime, creationTime, this.content}) {
    super.name = name;
    super.path = path;
    super.modificationTime = modificationTime;
    super.creationTime = creationTime;
  }

  factory File.fromFileInfo(FileInfo fileInfo) {
    return File(
      name: fileInfo.name,
      path: fileInfo.path,
      modificationTime: fileInfo.modificationTime,
      creationTime: fileInfo.creationTime
    );
  }

  @override
  isDirectory() {
    return false;
  }

  getContent() {
    return content;
  }

  loadContent() {

  }
}