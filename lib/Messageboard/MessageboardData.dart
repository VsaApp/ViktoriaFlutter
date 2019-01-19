import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Keys.dart';
import '../Network.dart';
import 'MessageboardModel.dart';

String urlGroupList = 'https://api.vsa.2bad2c0.de/messageboard/groups/list?v=' + new Random().nextInt(99999999).toString();
String urlGroupAdd = 'https://api.vsa.2bad2c0.de/messageboard/groups/add?v=' + new Random().nextInt(99999999).toString();
String urlGroupInfo = 'https://api.vsa.2bad2c0.de/messageboard/groups/info/'; // + GROUPNAME
String urlGroupLogin = 'https://api.vsa.2bad2c0.de/messageboard/groups/login'; // + GROUPNAME/PASSWORD
String urlGroupUpdate = 'https://api.vsa.2bad2c0.de/messageboard/groups/update'; // + GROUPNAME/PASSWORD
String urlGroupDelete = 'https://api.vsa.2bad2c0.de/messageboard/groups/delete'; // + GROUPNAME/PASSWORD
String urlGroupPosts = 'https://api.vsa.2bad2c0.de/messageboard/posts/list'; // + GROUPNAME/START/END
String urlPostAdd = 'https://api.vsa.2bad2c0.de/messageboard/posts/add'; // + GROUPNAME/PASSWORD
String urlPostUpdate = 'https://api.vsa.2bad2c0.de/messageboard/posts/update'; // + POSTID/PASSWORD
String urlPostDelete = 'https://api.vsa.2bad2c0.de/messageboard/posts/delete'; // + POSTID/PASSWORD
String urlFeed = 'https://api.vsa.2bad2c0.de/messageboard/feed';


Future download() async {
  await downloadGroups();
  await downloadFeed();
}

// Download messageboard data...
Future downloadGroups() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Messageboard.sharedPreferences = sharedPreferences;
  try {
    final response = await http.Client().get(urlGroupList).timeout(maxTime);
    // Save loaded data...
    sharedPreferences.setString(Keys.messageboardGroups, response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download: " + e.toString());
    if (sharedPreferences.getString(Keys.messageboardGroups) == null) {
      // Set default data...
      sharedPreferences.setString(Keys.messageboardGroups, '[]');
    }
  }

  // Parse loaded data...
  Messageboard.allGroups = await fetchGroups();
  Messageboard.updateGroupsStates();
}

// Download the user feed (Groups must be downloaded before!)...
Future downloadFeed({int start = 0, int end = 10, bool addFeed = false}) async {
  if (Messageboard.following.length == 0){
    Messageboard.feed = Feed(posts: []);
    return;
  }
  // If reloading data, set status to updating...
  if (!addFeed) {
    Messageboard.currentUpdateProcesses++;
    Messageboard.status = 'updating';
  }

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Messageboard.sharedPreferences = sharedPreferences;
  List<String> feedGroups = Messageboard.following.map((group) => group.name).toList();
  try {
    final response = await post('$urlFeed/$start/$end', body: {"groups": feedGroups});
    // Save loaded data...
    sharedPreferences.setString(Keys.messageboardFeed(start, end, feedGroups), response);

    await sharedPreferences.commit();
  } catch (e) {
    print("Error in download feed: " + e.toString());
    if (sharedPreferences.getString(Keys.messageboardFeed(start, end, feedGroups)) == null) {
      // Set default data...
      sharedPreferences.setString(Keys.messageboardFeed(start, end, feedGroups), '[]');
    }
  }

  // Only save data if there is no newer download process...
  if (!addFeed && Messageboard.currentUpdateProcesses > 1) {
    Messageboard.currentUpdateProcesses--;
    return;
  }

  // If during downloading all groups was disfollowed...
  if (Messageboard.following.length == 0){
    Messageboard.feed = Feed(posts: []);
    if (!addFeed) {
      Messageboard.currentUpdateProcesses--;
      Messageboard.status = 'updated';
    }
    return;
  }
  
  // Parse loaded data...
  int count = 0;
  if (Messageboard.feed != null && (addFeed ?? false)) count = Messageboard.feed.posts.length;
  if (addFeed) Messageboard.feed.addFeed(await fetchFeed(start, end, feedGroups));
  else Messageboard.feed = await fetchFeed(start, end, feedGroups);
  int loaded =  Messageboard.feed.posts.length - count;
  if (loaded < end - start) Messageboard.feed.loadComplete = true;

  // If data was reloaded, set status to 'updated'...
  if (!addFeed) {
    Messageboard.currentUpdateProcesses--;
    Messageboard.status = 'updated';
  }
}

Future downloadPosts(Group group, {int start, int end, bool addPosts = false}) async {
  String name = group.name;

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Messageboard.sharedPreferences = sharedPreferences;
  try {
    String url = '$urlGroupPosts/$name/$start/$end';
    final response = await http.Client().get(url).timeout(maxTime);
    // Save loaded data...
    sharedPreferences.setString(Keys.messageboardPosts(name, start, end), response.body);
    await sharedPreferences.commit();
  } catch (e) {
    print("Error during downloading posts: " + e.toString());
    if (sharedPreferences.getString(Keys.messageboardPosts(name, start, end)) == null) {
      // Set default data...
      sharedPreferences.setString(Keys.messageboardPosts(name, start, end), '[]');
    }
  }
  
  // Parse loaded data...
  int count = 0;
  if (group.posts != null && addPosts) count = group.posts.length;
  List<Post> posts = await fetchPosts(name, start, end);
  // Set the data in the group object...
  if (addPosts) group.posts.addAll(posts);
  else group.posts = posts;
  int loaded =  group.posts.length - count;
  if (loaded < end - start) group.loadComplete = true;
}

/// Update group data...
Future<bool> updateGroup({String username, String password, String newInfo, String newPassword}) async {
  try {
    String _url = '$urlGroupUpdate/$username/$password';
    final response = await post(_url, body: {'username': username, 'password': newPassword, 'info': newInfo});
    final parsed = json.decode(response);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error during updating group: " + e.toString());
    return false;
  }
}

/// Update post data...
Future<bool> updatePost({String id, String password, String newTitle, String newText}) async {
  try {
    String _url = '$urlPostUpdate/$id/$password';
    final response = await post(_url, body: {'title': newTitle, 'text': newText});
    final parsed = json.decode(response);
    print(_url);
    print(MessageboardError.fromJson(parsed).error);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error during updating post: " + e.toString());
    return false;
  }
}

/// Update post data...
Future<bool> deletePost({String id, String password}) async {
  try {
    String _url = '$urlPostDelete/$id/$password';
    final response = await http.Client().get(_url).timeout(maxTime);
    final parsed = json.decode(response.body);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error during deleting post: " + e.toString());
    return false;
  }
}

/// Remove a messageboard group
Future<bool> removeGroup({String username, String password}) async {
  try {
    String _url = '$urlGroupDelete/$username/$password';

    final response = await http.Client().get(_url).timeout(maxTime);
    final parsed = json.decode(response.body);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error during remove group: " + e.toString());
    return false;
  }
}

/// Adds a messageboard group
Future<bool> addGroup({String username, String password, String info}) async {
  try {
    final response = await post(urlGroupAdd, body: {'username': username, 'password': password, 'info': info});
    final parsed = json.decode(response);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error during adding group: " + e.toString());
    return false;
  }
}

Future<bool> addPost({String username, String password, String title, String text}) async {
  try {
    final response = await post('$urlPostAdd/$username/$password', body: {'title': title, 'text': text});
    final parsed = json.decode(response);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error in download: " + e.toString());
    return false;
  }
}


// Check the login data of the keyfob...
Future<bool> checkLogin({String username, String password}) async {
  try {
    String _url = '$urlGroupLogin/$username/$password';

    final response = await http.Client().get(_url).timeout(maxTime);
    final parsed = json.decode(response.body);
    return MessageboardError.fromJson(parsed).error == null;
  } catch (e) {
    print("Error in download: " + e.toString());
    return false;
  }
}

// Returns the static calendar data...
List<Group> getGroups() {
  return Messageboard.allGroups;
}

// Load posts of a group from preferences...
Future<List<Post>> fetchPosts(String name, int start, int end) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parsePosts(sharedPreferences.getString(Keys.messageboardPosts(name, start, end)));
}

// Load feed from preferences...
Future<Feed> fetchFeed(int start, int end, List<String> groups) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseFeed(sharedPreferences.getString(Keys.messageboardFeed(start, end, groups)));
}

// Load groups from preferences...
Future<List<Group>> fetchGroups() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return parseGroups(sharedPreferences.getString(Keys.messageboardGroups));
}

// Returns parsed posts...
List<Post> parsePosts(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

// Returns parsed feed...
Feed parseFeed(String responseBody) {
  final parsed = json.decode(responseBody);
  return Feed.fromJson(parsed.toList());
}

// Returns parsed messageboard groups...
List<Group> parseGroups(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed.map<Group>((json) => Group.fromJson(json)).toList();
}

