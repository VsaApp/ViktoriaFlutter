import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'dart:typed_data';

abstract class Element {
  String name;
  String path;
  DateTime modificationTime;
  List<int> shareTypes;

  /// 0: created, 1: created local, 2: not created
  int isCreated = 0;
  bool isDeleted = false;
  List<void Function()> _listeners = [];
  bool loading = false;

  Element(
      {this.name,
      this.path,
      this.modificationTime,
      this.shareTypes,
      this.isCreated = 0});

  void Function() addListener(void Function() listener) {
    _listeners.add(listener);
    return listener;
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);
  bool containsListener(void Function() listener) =>
      _listeners.contains(listener);

  void onUpdate(bool loading) {
    this.loading = loading;
    _listeners.forEach((_l) => _l());
  }

  bool isDirectory();

  Map<String, dynamic> toJson();

  factory Element.fromJson(Map<String, dynamic> json) {
    bool isDir = json['isDir'] as bool;
    return isDir ? Directory.fromJson(json) : File.fromJson(json);
  }
}

class Directory extends Element {
  List<Element> elements;

  Directory(
      {String name,
      String path,
      DateTime modificationTime,
      List<int> shareTypes,
      this.elements,
      int isCreated = 0})
      : super(
            name: name,
            path: path,
            modificationTime: modificationTime,
            shareTypes: shareTypes,
            isCreated: isCreated);

  factory Directory.fromFileInfo(WebDavFile fileInfo) {
    return Directory(
        name: fileInfo.name,
        path: fileInfo.path,
        modificationTime: fileInfo.lastModified,
        shareTypes: fileInfo.shareTypes);
  }

  @override
  isDirectory() {
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'modificationTime': modificationTime.toIso8601String(),
      'shareTypes': shareTypes,
      'isDir': true,
      'elements':
          elements != null ? elements.map((e) => e.toJson()).toList() : null
    };
  }

  factory Directory.fromJson(Map<String, dynamic> json) {
    return Directory(
      name: json['name'] as String,
      path: json['path'] as String,
      modificationTime: DateTime.parse(json['modificationTime'] as String),
      shareTypes: json['shareTypes'].cast<int>().toList(),
      elements: json['elements'] != null
          ? json['elements']
              .map<Element>((json) => Element.fromJson(json))
              .toList()
          : null,
    );
  }

  List<File> getFiles() {
    return elements
        .where((element) => !element.isDirectory())
        .toList()
        .cast<File>();
  }

  List<Directory> getDirectories() {
    return elements
        .where((element) => element.isDirectory())
        .toList()
        .cast<Directory>();
  }
}

class File extends Element {
  Uint8List content;

  File(
      {String name,
      String path,
      DateTime modificationTime,
      List<int> shareTypes,
      this.content,
      int isCreated = 0})
      : super(
            name: name,
            path: path,
            modificationTime: modificationTime,
            shareTypes: shareTypes,
            isCreated: isCreated);

  factory File.fromFileInfo(WebDavFile fileInfo) {
    return File(
        name: fileInfo.name,
        path: fileInfo.path,
        modificationTime: fileInfo.lastModified,
        shareTypes: fileInfo.shareTypes);
  }

  @override
  isDirectory() {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'modificationTime': modificationTime.toIso8601String(),
      'shareTypes': shareTypes,
      'isDir': false
    };
  }

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
        name: json['name'] as String,
        path: json['path'] as String,
        modificationTime: DateTime.parse(json['modificationTime'] as String),
        shareTypes: json['shareTypes'].cast<int>().toList());
  }

  getContent() {
    return content;
  }

  loadContent() {}
}

class Choice {
  Choice(
    this.icon,
    this.label, {
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool enabled;
}
