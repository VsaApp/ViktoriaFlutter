import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Duration maxTime = Duration(seconds: 4);

/// Returns 1 if api.vsa.2bad2c0.de is online, 0 if google.com is online and -1 if everthing is offline
Future<int> get checkOnline async {
  try {
    final result1 = await InternetAddress.lookup('api.vsa.2bad2c0.de').timeout(maxTime);
    if (result1.isNotEmpty && result1[0].rawAddress.isNotEmpty) {
      return 1;
    }
    final result2 = await InternetAddress.lookup('google.com').timeout(maxTime);
    if (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) {
      return 0;
    }
    return -1;
  } on SocketException catch (_) {
    return -1;
  }
}

Future fetchDataAndSave(String url, String key, String defaultValue) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    final response = await http.Client().get(url).timeout(maxTime);
    sharedPreferences.setString(key, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error during downloading \'$key\': " + e.toString());
    if (sharedPreferences.getString(key) == null) {
      sharedPreferences.setString(key, defaultValue);
    }
  }
}

Future<String> fetchData(String url) async {
  try {
    final response = await http.Client().get(url).timeout(maxTime);
    return response.body;
  } catch (e) {
    print("Error druing fetching date ($url): " + e.toString());
    return "";
  }
}

Future<String> post(String url, {dynamic body}) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url)).timeout(maxTime);
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close().timeout(maxTime);
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join().timeout(maxTime);
  httpClient.close();
  return reply;
}