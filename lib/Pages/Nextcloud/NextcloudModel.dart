import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';

/// Defines an nextcloud element
abstract class Element {
  /// The element name
  String name;

  /// Element path (in url encoding)
  String path;

  /// The last modification time
  DateTime modificationTime;

  /// A list of all used share types
  List<int> shareTypes;

  /// 0: created, 1: created local, 2: not created
  int isCreated = 0;

  /// Defines if the element was deleted
  bool isDeleted = false;

  /// Defines all changed listeners
  final List<void Function()> _listeners = [];

  /// Defines if the element is loading
  bool loading = false;

  // ignore: public_member_api_docs
  Element(
      {this.name,
      this.path,
      this.modificationTime,
      this.shareTypes,
      this.isCreated = 0});

  /// Add an update listener
  void Function() addListener(void Function() listener) {
    _listeners.add(listener);
    return listener;
  }

  /// Remove an update listener
  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// Checks if an update listener is still set
  bool containsListener(void Function() listener) =>
      _listeners.contains(listener);

  /// Updates an element
  void onUpdate(bool loading) {
    this.loading = loading;
    _listeners.forEach((_l) => _l());
  }

  /// Checks if it is an directory
  bool isDirectory();

  /// Converts element to json map
  Map<String, dynamic> toJson();

  /// Creates an element from a json map
  factory Element.fromJson(Map<String, dynamic> json) {
    final bool isDir = json['isDir'] as bool;
    return isDir ? Directory.fromJson(json) : File.fromJson(json);
  }
}

/// Defines an nextcloud directory
class Directory extends Element {
  /// All sub elements
  ///
  /// `null`: not loaded
  List<Element> elements;

  // ignore: public_member_api_docs
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

  /// Creates an directory from a web dav file
  factory Directory.fromWebDavFile(WebDavFile fileInfo) {
    return Directory(
        name: fileInfo.name,
        path: fileInfo.path,
        modificationTime: fileInfo.lastModified,
        shareTypes: fileInfo.shareTypes);
  }

  @override
  bool isDirectory() => true;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'modificationTime': modificationTime.toIso8601String(),
      'shareTypes': shareTypes,
      'isDir': true,
      'elements': elements?.map((e) => e.toJson())?.toList()
    };
  }

  /// Creates an directory from json map
  factory Directory.fromJson(Map<String, dynamic> json) {
    return Directory(
      name: json['name'] as String,
      path: json['path'] as String,
      modificationTime: DateTime.parse(json['modificationTime'] as String),
      shareTypes: json['shareTypes'].cast<int>().toList(),
      elements: json['elements']
          ?.map<Element>((json) => Element.fromJson(json))
          ?.toList(),
    );
  }

  /// Returns all subfiles
  List<File> getFiles() {
    return elements
        .where((element) => !element.isDirectory())
        .toList()
        .cast<File>();
  }

  /// Returns all subdirectories
  List<Directory> getDirectories() {
    return elements
        .where((element) => element.isDirectory())
        .toList()
        .cast<Directory>();
  }
}

/// Describes an nextcloud file
class File extends Element {
  /// The binary file content
  Uint8List content;

  // ignore: public_member_api_docs
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

  /// Creates a file from an web dav file
  factory File.fromWebDavFile(WebDavFile fileInfo) {
    return File(
        name: fileInfo.name,
        path: fileInfo.path,
        modificationTime: fileInfo.lastModified,
        shareTypes: fileInfo.shareTypes);
  }

  @override
  bool isDirectory() => false;

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

  /// Creates a file from a json map
  factory File.fromJson(Map<String, dynamic> json) {
    return File(
        name: json['name'] as String,
        path: json['path'] as String,
        modificationTime: DateTime.parse(json['modificationTime'] as String),
        shareTypes: json['shareTypes'].cast<int>().toList());
  }
}

/// Defines a nextcloud element option choice
class Choice {
  // ignore: public_member_api_docs
  Choice(
    this.icon,
    this.label, {
    this.enabled = true,
  });

  /// The choice icon
  final IconData icon;

  /// The choice label
  final String label;

  /// If the choice is enabled
  final bool enabled;
}
