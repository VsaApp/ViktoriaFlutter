import 'Id.dart';
import 'Network.dart';
import 'Storage.dart';
import 'Keys.dart';

void init() async {
  List<String> bugs = Storage.getStringList(Keys.bugs) ?? [];
  if (bugs.length > 0 && (await checkOnline) == 1) {
    bugs.forEach((String bug) {
      reportError(bug.split(':|:')[0], bug.split(':|:')[1]);
    });
    Storage.setStringList(Keys.bugs, []);
  }
}

void reportError(error, stackTrace) async {
  print("Report new bug ($error)");
  if ((await checkOnline) == 1) {
    String url = 'https://api.vsa.2bad2c0.de/bugs/report';
    post(url, body: {
      "id": Id.id,
      "title": error.toString(),
      "error": stackTrace.toString()
    });
  } else {
    Storage.setStringList(Keys.bugs, Storage.getStringList(Keys.bugs)..add('$error:|:$stackTrace'));
  }
}

