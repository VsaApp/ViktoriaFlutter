import 'Models/CafetoriaModel.dart';
import 'Models/CalendarModel.dart';
import 'Models/SubstitutionPlanModel.dart';
import 'Models/TagsModel.dart';
import 'Models/TeachersModel.dart';
import 'Models/TimetableModel.dart';
import 'Models/UpdatesModel.dart';
import 'Models/WorkGroupsModel.dart';
export 'Models/CafetoriaModel.dart';
export 'Models/CalendarModel.dart';
export 'Models/SubjectRowDetails.dart';
export 'Models/SubstitutionPlanModel.dart';
export 'Models/TagsModel.dart';
export 'Models/TeachersModel.dart';
export 'Models/TimetableModel.dart';
export 'Models/UpdatesModel.dart';
export 'Models/WorkGroupsModel.dart';

/// All loaded data
class Data {
  // ignore: public_member_api_docs
  static Timetable timetable;
  // ignore: public_member_api_docs
  static SubstitutionPlan substitutionPlan;
  // ignore: public_member_api_docs
  static Calendar calendar;
  // ignore: public_member_api_docs
  static Cafetoria cafetoria;
  // ignore: public_member_api_docs
  static Map<String, String> rooms;
  // ignore: public_member_api_docs
  static List<Teacher> teachers;
  // ignore: public_member_api_docs
  static WorkGroups workGroups;
  // ignore: public_member_api_docs
  static Map<String, String> subjects;
  // ignore: public_member_api_docs
  static Updates updates;
  // ignore: public_member_api_docs
  static Tags tags;
}
