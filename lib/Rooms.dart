import 'package:shared_preferences/shared_preferences.dart';
import './Keys.dart';

String getRoom(SharedPreferences sharedPreferences, int weekday, int unit,
    String subject, String room) {
  subject = subject.toUpperCase();
  room = room.toUpperCase();
  if (sharedPreferences.getString(Keys.room(weekday, unit, subject)) == null) {
    return room;
  } else {
    return sharedPreferences.getString(Keys.room(weekday, unit, subject));
  }
}

void setRoom(SharedPreferences sharedPreferences, int weekday, int unit,
    String subject, String room) {
  subject = subject.toUpperCase();
  room = room.toUpperCase();
  sharedPreferences.setString(Keys.room(weekday, unit, subject), room);
  sharedPreferences.commit();
}
