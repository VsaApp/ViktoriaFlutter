import 'dart:convert';

import 'package:nextcloud/nextcloud.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'dart:io';
import 'dart:typed_data';

import './NextcloudModel.dart';

const baseUrl = 'nextcloud.aachen-vsa.logoip.de';

class Nextcloud {
  static NextCloudClient client;
  static Directory baseDir;

  static void init() {
    if (client != null && baseDir != null) return;
    client = NextCloudClient(baseUrl, Storage.getString(Keys.username),
        Storage.getString(Keys.password));
    String savedJson = Storage.getString(Keys.nextcloud);
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

  static void save() async {
    String parsed = json.encode(baseDir.toJson());
    Storage.setString(Keys.nextcloud, parsed);
  }

  static Future<File> loadFile(File file) async {
    if (file.loading) return file;
    Uint8List data = await client.webDav.download(file.path);
    file.content = data;
    return file;
  }

  static Future uploadFile(File file) async {
    if (file.loading) return;
    file.onUpdate(true);
    await client.webDav.upload(file.content, file.path);
    file.onUpdate(false);
  }

  static Future mkDir(Directory directory) async {
    if (directory.loading) return;
    directory.onUpdate(true);
    await client.webDav.mkdir(directory.path);
    directory.onUpdate(false);
  }

  static Future rename(Element element, String newName) async {
    if (element.loading) return;
    element.onUpdate(true);
    String encodedName = Uri.encodeFull(newName);
    String oldPath = element.path;
    List<String> path = element.path.split('/');
    path.removeAt(path.length - 2);
    path.insert(path.length - 1, encodedName);
    element.path = path.join('/');
    element.name = newName;
    try {
      await client.webDav.move(oldPath, element.path);
    } catch (_) {}
    element.onUpdate(false);
  }

  static Future delete(Element element) async {
    if (element.loading) return;
    element.onUpdate(true);
    try {
      await client.webDav.delete(element.path);
    } catch (_) {}
    element.onUpdate(false);
  }

  static Future<void> loadDirectory(Directory directory) async {
    if (directory.loading) return;
    directory.loading = true;
    List<WebDavFile> files = await client.webDav.ls(directory.path);

    if (directory.path == '/')
      files = files.where((file) => file.name != 'Programme').toList();

    List<Element> elements = files.map((element) {
      if (element.isDirectory) {
        return Directory.fromFileInfo(element);
      } else {
        return File.fromFileInfo(element);
      }
    }).toList();
    if (directory.elements != null) {
      List<String> newNames = elements.map((e) => e.name).toList();
      directory.elements = directory.elements
          .where((element) => newNames.contains(element.name))
          .toList();
      List<String> oldNames = directory.elements.map((e) => e.name).toList();
      // Update the elements of the directory
      elements.forEach((element) {
        if (oldNames.contains(element.name)) {
          Element oldElement =
              directory.elements[oldNames.indexOf(element.name)];
          oldElement.modificationTime = element.modificationTime;
          oldElement.shareTypes = element.shareTypes;
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
