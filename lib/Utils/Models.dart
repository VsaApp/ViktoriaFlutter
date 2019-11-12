export 'Models/TimetableModel.dart';
export 'Models/CafetoriaModel.dart';
export 'Models/CalendarModel.dart';
export 'Models/SubstitutionPlanModel.dart';
export 'Models/TeachersModel.dart';
export 'Models/WorkGroupsModel.dart';
export 'Models/UpdatesModel.dart';
import 'Models/TimetableModel.dart';
import 'Models/CafetoriaModel.dart';
import 'Models/CalendarModel.dart';
import 'Models/SubstitutionPlanModel.dart';
import 'Models/TeachersModel.dart';
import 'Models/WorkGroupsModel.dart';
import 'Models/UpdatesModel.dart';

class Data {
  static Timetable timetable;
  static SubstitutionPlan substitutionPlan;
  static Calendar calendar;
  static Cafetoria cafetoria;
  static Map<String, String> rooms;
  static List<Teacher> teachers;
  static WorkGroups workGroups;
  static Map<String, String> subjects;
  static Updates updates;
}
