import 'package:webdav/webdav.dart';
import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;

import './NextcloudModel.dart';

const baseUrl = 'https://nextcloud.aachen-vsa.logoip.de/remote.php/dav';

Future<Directory> load() async {
  Directory rootDirectory = Directory(name: 'Home', path: '/');
  return await loadDirectory(rootDirectory, 'fingege', 'infonatik2');
}

Future<File> loadFile(File file, String username, String password) async {
  String data = await openUrl('$baseUrl/files/$username/${file.path}', username, password, 'GET');
  file.content = data;
  return file;
}

Future uploadFile(File file, String username, String password) async {
  await openUrl('$baseUrl/files/$username/${file.path}', username, password, 'POST');
}

Future<Directory> loadDirectory(Directory directory, String username, String password) async {
  String data = await openUrl('$baseUrl/files/$username/${directory.path}', username, password, 'PROPFIND');
  print('loaded');
  List<FileInfo> content = treeFromWebDavXml(data);

  List<Element> elements = content.sublist(1).map((element) {
    element.path = element.path.split('$username/')[1];
    if (element.isDirectory) {
      return Directory.fromFileInfo(element);
    }
    else {
      return File.fromFileInfo(element);
    }
  }).toList();
  directory.elements = elements;
  return directory;
}

Future<String> openUrl(String url, String username, String password, String method, {Function decoder}) async {
  HttpClient client = HttpClient();
  client.addCredentials(Uri.parse(url), '', HttpClientBasicCredentials(username, password));
  HttpClientRequest request = await client.openUrl(method, Uri.parse(url));
  HttpClientResponse response = await request.close();
  return await response.transform(decoder  ?? utf8.decoder).join();
} 

List<FileInfo> treeFromWebDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  var tree = new List<FileInfo>();

  // parse the xml using the xml.parse method
  var xmlDocument = xml.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  findAllElementsFromDocument(xmlDocument, "response").forEach((response) {
    var davItemName = findElementsFromElement(response, "href").single.text;
    findElementsFromElement(
            findElementsFromElement(response, "propstat").first, "prop")
        .forEach((element) {
      final contentLengthElements =
          findElementsFromElement(element, "getcontentlength");
      final contentLength = contentLengthElements.isNotEmpty
          ? contentLengthElements.single.text
          : "";

      final lastModifiedElements =
          findElementsFromElement(element, "getlastmodified");
      final lastModified = lastModifiedElements.isNotEmpty
          ? lastModifiedElements.single.text
          : "";

      final creationTimeElements =
          findElementsFromElement(element, "creationdate");
      final creationTime = creationTimeElements.isNotEmpty
          ? creationTimeElements.single.text
          : DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      // Add the just found file to the tree
      tree.add(new FileInfo(davItemName, contentLength, lastModified,
          DateTime.parse(creationTime), ""));
    });
  });

  // Return the tree
  return tree;
}

List<xml.XmlElement> findAllElementsFromDocument(
        xml.XmlDocument document, String tag) =>
    (document.findAllElements("d:$tag").toList()
      ..addAll(document.findAllElements("D:$tag")));

List<xml.XmlElement> findElementsFromElement(
        xml.XmlElement element, String tag) =>
    (element.findElements("d:$tag").toList()
      ..addAll(element.findElements("D:$tag")));