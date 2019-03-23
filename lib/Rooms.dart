import 'Keys.dart';
import 'Storage.dart';

String getRoom(int weekday, int unit, String subject, String room) {
  subject = subject.toUpperCase();
  if (Storage.getString(Keys.room(weekday, unit, subject)) == null) {
    return room;
  } else {
    return Storage.getString(Keys.room(weekday, unit, subject));
  }
}

void setRoom(int weekday, int unit, String subject, String room) {
  subject = subject.toUpperCase();
  Storage.setString(Keys.room(weekday, unit, subject), room);
}
