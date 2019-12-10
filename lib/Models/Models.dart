import 'package:viktoriaflutter/Models/CafetoriaModel.dart';
import 'package:viktoriaflutter/Models/CalendarModel.dart';
import 'package:viktoriaflutter/Models/SubstitutionPlanModel.dart';
import 'package:viktoriaflutter/Models/TagsModel.dart';
import 'package:viktoriaflutter/Models/TeachersModel.dart';
import 'package:viktoriaflutter/Models/TimetableModel.dart';
import 'package:viktoriaflutter/Models/UpdatesModel.dart';
import 'package:viktoriaflutter/Models/WorkGroupsModel.dart';
export 'package:viktoriaflutter/Models/CafetoriaModel.dart';
export 'package:viktoriaflutter/Models/CalendarModel.dart';
export 'package:viktoriaflutter/Models/SubjectRowDetails.dart';
export 'package:viktoriaflutter/Models/SubstitutionPlanModel.dart';
export 'package:viktoriaflutter/Models/TagsModel.dart';
export 'package:viktoriaflutter/Models/TeachersModel.dart';
export 'package:viktoriaflutter/Models/TimetableModel.dart';
export 'package:viktoriaflutter/Models/UpdatesModel.dart';
export 'package:viktoriaflutter/Models/WorkGroupsModel.dart';

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
