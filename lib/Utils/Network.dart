import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

Duration maxTime = Duration(seconds: 4);
String apiUrl = 'https://vsa.fingeg.de';
String lookupUrl = 'vsa.fingeg.de';
String agbUrl = 'https://vsa.2bad2c0.de/agb.html';
String historyUrl = 'https://vsa.fingeg.de/history';

class Urls {
  static String get updates => '/updates?v=$_getRandomInt';
  static String get cafetoriaList => '/cafetoria/list?v=$_getRandomInt';
  static String cafetoriaLogin(String id, String password) =>
      '/cafetoria/login/$id/$password?v=$_getRandomInt';
  static String get calendar => '/calendar?v=$_getRandomInt';
  static String get login => '/login?v=$_getRandomInt';
  static String get subjects => '/subjects?v=$_getRandomInt';
  static String get substitutionPlan => '/substitutionplan?v=$_getRandomInt';
  static String get teachers => '/teachers?v=$_getRandomInt';
  static String get timetable => '/timetable?v=$_getRandomInt';
  static String get bugReport => '/bugs/report?v=$_getRandomInt';
  static String get tags => '/tags?v=$_getRandomInt';
  static String get workgroups => '/workgroups?v=$_getRandomInt';
  static String get rooms => '/rooms?v=$_getRandomInt';

  static String get _getRandomInt => Random().nextInt(99999999).toString();
}

class Response {
  final String body;
  final int statusCode;

  Response({this.body, this.statusCode});
}

/// Returns 1 if the api is online, 0 if google.com is online and -1 if everything is offline
Future<int> get checkOnline async {
  try {
    final result1 = await InternetAddress.lookup(lookupUrl).timeout(maxTime);
    if (result1.isNotEmpty && result1[0].rawAddress.isNotEmpty) {
      return 1;
    }
    final result2 = await InternetAddress.lookup('google.com').timeout(maxTime);
    if (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) {
      return 0;
    }
    return -1;
  } on Exception catch (_) {
    return -1;
  }
}

String getUrl(String path, {bool auth = true}) {
  String authString = auth
      ? '${Storage.getString(Keys.username) ?? ''}:${Storage.getString(Keys.password) ?? ''}@'
      : '';
  if (path.contains('@')) authString = '';
  if (path.contains('http')) return path.replaceFirst('://', '://$authString');
  if (!path.startsWith('/')) path = '/' + path;
  return '$apiUrl$path'.replaceFirst('://', '://$authString');
}

Future fetchDataAndSave(String url, String key, String defaultValue,
    {Map<String, dynamic> body,
    Duration timeout,
    bool auth = true,
    void Function(int successfully) onFinished}) async {
  if (timeout == null) {
    timeout = maxTime;
  }
  if (body == null) url = getUrl(url, auth: auth);
  Response response;
  try {
    if (body != null) {
      response = await httpRequest(url, 'POST', body: body);
    } else {
      http.Response _response = await http.Client().get(url).timeout(timeout);
      response = Response(body: _response.body, statusCode: _response.statusCode);
    }
    if (response.statusCode == 404 || response.body.contains('404 Not Found')) {
      throw "404 Not Found";
    }
    Storage.setString(key, response.body);
    if (onFinished != null) onFinished(response.statusCode);
  } catch (e) {
    print("Error during downloading \'$key\': " + e.toString());
    if (Storage.getString(key) == null) {
      Storage.setString(key, defaultValue);
    }
    if (onFinished != null) onFinished((response ?? Response(statusCode: -1)).statusCode);
  }
}

Future<http.Response> fetch(String url,
    {Duration timeout, bool auth = true}) async {
  if (timeout == null) {
    timeout = maxTime;
  }
  url = getUrl(url, auth: auth);
  try {
    final response = await http.Client().get(url).timeout(timeout);
    return response;
  } catch (e) {
    print("Error during fetching ($url): " + e.toString());
    return null;
  }
}

Future<String> fetchData(String url,
    {Duration timeout, bool auth = true}) async {
  http.Response response = await fetch(url, timeout: timeout, auth: auth);
  if (response == null) {
    return '';
  }
  return response.body;
}

Future<String> httpPost(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'POST', body: body, auth: auth)).body;
}

Future<String> httpPut(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'PUT', body: body, auth: auth)).body;
}

Future<String> httpDelete(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'DELETE', body: body, auth: auth)).body;
}

Future<Response> httpRequest(String url, String method,
    {dynamic body, bool auth = true}) async {
  url = getUrl(url, auth: auth);
  HttpClient httpClient = HttpClient();
  HttpClientRequest request;
  if (method == 'POST')
    request = await httpClient.postUrl(Uri.parse(url)).timeout(maxTime);
  else if (method == 'DELETE')
    request = await httpClient.deleteUrl(Uri.parse(url)).timeout(maxTime);
  else if (method == 'PUT')
    request = await httpClient.putUrl(Uri.parse(url)).timeout(maxTime);
  else if (method == 'GET')
    request = await httpClient.getUrl(Uri.parse(url)).timeout(maxTime);
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close().timeout(maxTime);
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join().timeout(maxTime);
  httpClient.close();
  return Response(body: reply, statusCode: response.statusCode);
}
