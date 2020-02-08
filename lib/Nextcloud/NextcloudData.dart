import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nextcloud/nextcloud.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';

import 'package:viktoriaflutter/Nextcloud/NextcloudModel.dart';

/// Base url of the nextcloud
const baseUrl = 'nextcloud.aachen-vsa.logoip.de';

/// Handles the nextcloud data
class Nextcloud {
  /// The nextcloud client
  static NextCloudClient client;

  /// The user home directory
  static Directory baseDir;

  /// Initialize the nextcloud client and loads cached data
  static void init() {
    if (client != null && baseDir != null) {
      return;
    }
    client = NextCloudClient(baseUrl, Storage.getString(Keys.username),
        Storage.getString(Keys.password));
    final String savedJson = Storage.getString(Keys.nextcloud);
    if (savedJson != null) {
      baseDir = Directory.fromJson(json.decode(savedJson));
    } else {
      baseDir = Directory(
          name: 'Home',
          path: '/',
          modificationTime: DateTime.now(),
          shareTypes: []);
    }
  }

  /// Save directory structure in preferences
  static Future<void> save() async {
    final String parsed = json.encode(baseDir.toJson());
    Storage.setString(Keys.nextcloud, parsed);
  }

  /// Loads the content of a file
  static Future<File> loadFile(File file) async {
    if (file.loading) {
      return file;
    }
    final Uint8List data = await client.webDav.download(file.path);
    file.content = data;
    return file;
  }

  /// Uploads a file
  static Future uploadFile(File file) async {
    file.onUpdate(true);
    await client.webDav.upload(file.content, file.path);
    file.onUpdate(false);
    save();
  }

  /// Creates a new directory
  static Future mkDir(Directory directory) async {
    if (directory.loading) {
      return;
    }
    directory.onUpdate(true);
    await client.webDav.mkdir(directory.path);
    directory.onUpdate(false);
    save();
  }

  /// Renames an given [element] to the given [newName]
  static Future rename(Element element, String newName) async {
    if (element.loading) {
      return;
    }
    element.onUpdate(true);
    final String encodedName = Uri.encodeFull(newName);
    final String oldPath = element.path;
    final List<String> path = element.path.split('/');
    path
      ..removeAt(path.length - 2)
      ..insert(path.length - 1, encodedName);
    element
      ..path = path.join('/')
      ..name = newName;
    try {
      await client.webDav.move(oldPath, element.path);
    } catch (_) {}
    element.onUpdate(false);
    save();
  }

  /// Deletes a given [element]
  static Future delete(Element element, Directory parentDir) async {
    if (element.loading) {
      return;
    }
    element
      ..isDeleted = true
      ..isCreated = 1
      ..onUpdate(true);
    try {
      await client.webDav.delete(element.path);
    } catch (_) {}
    parentDir.elements.remove(element);
    element.onUpdate(false);
    parentDir.onUpdate(false);
    save();
  }

  /// Loads all sub elements of a directory
  static Future<void> loadDirectory(Directory directory) async {
    if (directory.loading) {
      return;
    }
    directory.loading = true;
    List<WebDavFile> files = await client.webDav.ls(directory.path);

    if (directory.path == '/') {
      files = files.where((file) => file.name != 'Programme').toList();
    }

    final List<Element> elements = files.map((element) {
      if (element.isDirectory) {
        return Directory.fromWebDavFile(element);
      } else {
        return File.fromWebDavFile(element);
      }
    }).toList();
    if (directory.elements != null) {
      final List<String> newNames = elements.map((e) => e.name).toList();
      directory.elements = directory.elements
          .where((element) => newNames.contains(element.name))
          .toList();
      final List<String> oldNames =
          directory.elements.map((e) => e.name).toList();
      // Update the elements of the directory
      elements.forEach((element) {
        if (oldNames.contains(element.name)) {
          directory.elements[oldNames.indexOf(element.name)]
            ..modificationTime = element.modificationTime
            ..shareTypes = element.shareTypes
            ..path = element.path;
        } else {
          directory.elements.add(element);
        }
      });
    } else {
      directory.elements = elements;
    }
    // Sort the elements
    directory.elements.sort((e1, e2) => e1.isDirectory()
        ? e2.isDirectory() ? 0 : -1
        : e2.isDirectory() ? 1 : 0);
    directory.onUpdate(false);
    save();
  }
}
