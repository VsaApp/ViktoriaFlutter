import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

/// The max download time
Duration maxTime = Duration(seconds: 4);

/// The base api url
String apiUrl = 'https://vsa.fingeg.de';

/// The url fro online lookups
String lookupUrl = 'vsa.fingeg.de';

/// The url to the agbs
String agbUrl = 'https://vsa.2bad2c0.de/agb.html';

/// The history url
String historyUrl = 'https://vsa.fingeg.de/history';

/// Define logging request url
bool logRequest = false;

/// Define all sub urls (paths) for the request
class Urls {
  // ignore: public_member_api_docs
  static String get updates => '/updates?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get cafetoriaList => '/cafetoria/list?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get cafetoria => '/cafetoria?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get calendar => '/calendar?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get login => '/login?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get subjects => '/subjects?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get substitutionPlan => '/substitutionplan?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get teachers => '/teachers?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get timetable => '/timetable?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get bugReport => '/bugs/report?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get tags => '/tags?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get workgroups => '/workgroups?v=$_getRandomInt';

  // ignore: public_member_api_docs
  static String get rooms => '/rooms?v=$_getRandomInt';

  static String get _getRandomInt => Random().nextInt(99999999).toString();
}

/// Http status codes
class StatusCodes {
  // ignore: public_member_api_docs
  static int get success => 200;

  // ignore: public_member_api_docs
  static int get timeout => 408;

  // ignore: public_member_api_docs
  static int get notFound => 404;

  // ignore: public_member_api_docs
  static int get unauthorized => 401;

  // ignore: public_member_api_docs
  static int get offline => -1;

  // ignore: public_member_api_docs
  static int get failed => -100;
}

/// Describes a response
class Response {
  /// The raw [body] string
  final String body;

  /// The request [statusCode]
  final int statusCode;

  // ignore: public_member_api_docs
  Response({this.body, this.statusCode});
}

/// Returns 1 if the api is online, 0 if google.com is online and -1 if everything is offline
Future<int> get checkOnline async {
  final int online = await _checkOnline;
  if (logRequest) {
    print('online: $online');
  }
  return online;
}

Future<int> get _checkOnline async {
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

void _logRequest(int statusCode, String method, String url) {
  // ignore: prefer_single_quotes
  url = url.replaceFirst(RegExp(r"https:\/\/.+@"), 'https://');
  if (logRequest) {
    print('Request finished with $statusCode: $method $url');
  }
}

/// Returns an url with the correct authentication
String getUrl(String path, {bool auth = true}) {
  String authString = auth
      ? '${Storage.getString(Keys.username) ?? ''}:${Storage.getString(Keys.password) ?? ''}@'
      : '';
  if (path.contains('@')) {
    authString = '';
  }
  if (path.contains('http')) {
    return path.replaceFirst('://', '://$authString');
  }
  if (!path.startsWith('/')) {
    path = '/$path';
  }
  return '$apiUrl$path'.replaceFirst('://', '://$authString');
}

/// Fetches data from [url] and saves it with the given [key] in the preferences
Future fetchDataAndSave(String url, String key, String defaultValue,
    {Map<String, dynamic> body,
    Duration timeout,
    bool auth = true,
    void Function(int successfully) onFinished}) async {
  timeout ??= maxTime;
  url = getUrl(url, auth: auth);
  Response response;
  try {
    if (body != null) {
      response = await httpRequest(url, 'POST', body: body);
    } else {
      response = await request(url, timeout);
    }
    if (response.statusCode == StatusCodes.notFound ||
        response.body.contains('404 Not Found')) {
      throw Exception('404 Not Found');
    }
    if (response.statusCode == StatusCodes.success) {
      Storage.setString(key, response.body);
    }
    if (onFinished != null) {
      onFinished(response.statusCode);
    }
  } catch (e) {
    print('Error during downloading \'$key\': $e');
    if (Storage.getString(key) == null) {
      Storage.setString(key, defaultValue);
    }
    response ??= Response(statusCode: StatusCodes.offline);
    if (onFinished != null) {
      onFinished(response.statusCode ?? StatusCodes.offline);
    }
  }
}

/// Request to the given [url]
Future<Response> request(String url, Duration timeout) async {
  final response = await http.Client().get(url).timeout(timeout);
  _logRequest(response.statusCode, 'GET', url);
  return Response(body: response.body, statusCode: response.statusCode);
}

/// Fetches data from [url]
Future<Response> fetch(String url, {Duration timeout, bool auth = true}) async {
  timeout ??= maxTime;
  url = getUrl(url, auth: auth);
  try {
    return await request(url, timeout);
  } on TimeoutException catch (_) {
    return Response(body: '', statusCode: StatusCodes.timeout);
  } on SocketException catch (_) {
    print('Cannot fetch $url');
    return Response(body: '', statusCode: StatusCodes.offline);
  } catch (e) {
    print('Error during fetching ($url): $e');
    return Response(body: '', statusCode: StatusCodes.failed);
  }
}

/// http POST request
Future<String> httpPost(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'POST', body: body, auth: auth)).body;
}

/// http PUT request
Future<String> httpPut(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'PUT', body: body, auth: auth)).body;
}

/// http DELETE request
Future<String> httpDelete(String url, {dynamic body, bool auth = true}) async {
  return (await httpRequest(url, 'DELETE', body: body, auth: auth)).body;
}

/// http request to given [url] with given [method]
Future<Response> httpRequest(String url, String method,
    {dynamic body, bool auth = true}) async {
  final Response response =
      await _httpRequest(url, method, body: body, auth: auth);
  _logRequest(response.statusCode, method, url);
  return response;
}

Future<Response> _httpRequest(String url, String method,
    {dynamic body, bool auth = true}) async {
  url = getUrl(url, auth: auth);
  HttpClientResponse response;
  try {
    final HttpClient httpClient = HttpClient();
    HttpClientRequest request;
    if (method == 'POST') {
      request = await httpClient.postUrl(Uri.parse(url)).timeout(maxTime);
    } else if (method == 'DELETE') {
      request = await httpClient.deleteUrl(Uri.parse(url)).timeout(maxTime);
    } else if (method == 'PUT') {
      request = await httpClient.putUrl(Uri.parse(url)).timeout(maxTime);
    } else if (method == 'GET') {
      request = await httpClient.getUrl(Uri.parse(url)).timeout(maxTime);
    }
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(body)));
    response = await request.close().timeout(maxTime);
    // todo - you should check the response.statusCode
    final String reply =
        await response.transform(utf8.decoder).join().timeout(maxTime);
    httpClient.close();
    return Response(body: reply, statusCode: response.statusCode);
  } catch (e) {
    if (response != null) {
      return Response(statusCode: response.statusCode);
    } else {
      return Response(statusCode: StatusCodes.offline);
    }
  }
}
