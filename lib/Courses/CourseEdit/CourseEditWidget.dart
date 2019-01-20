import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Keys.dart';
import '../../UnitPlan/UnitPlanModel.dart';
import '../../UnitPlan/UnitPlanData.dart' as UnitPlan;
import 'CourseEditView.dart';

class CourseEdit extends StatefulWidget {
  final UnitPlanSubject subject;
  final List<String> blocks;
  final Function onExamChange;

  CourseEdit(
      {Key key,
      @required this.subject,
      @required this.blocks,
      this.onExamChange})
      : super(key: key);

  @override
  CourseEditView createState() => CourseEditView();
}

abstract class CourseEditState extends State<CourseEdit> {
  SharedPreferences sharedPreferences;
  bool exams = false;
  List<dynamic> subjects1 = [];

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      setState(() {
        sharedPreferences = instance;
        exams = sharedPreferences
                .getBool(Keys.exams(sharedPreferences.getString(Keys.grade), widget.subject.lesson.toUpperCase())) ??
            true;
      });
      List<UnitPlanDay> days = UnitPlan.getUnitPlan();
      days.forEach((day) {
        day.lessons.forEach((lesson) {
          int _selected = sharedPreferences.getInt(Keys.unitPlan(
              sharedPreferences.getString(Keys.grade),
              block: lesson.subjects[0].block,
              day: days.indexOf(day),
              unit: day.lessons.indexOf(lesson)));
          if (_selected == null) return;
          if (lesson.subjects[_selected].lesson == widget.subject.lesson) {
            subjects1.add({
              'weekday': days.indexOf(day),
              'unit': day.lessons.indexOf(lesson),
              'subject': lesson.subjects[_selected]
            });
          }
        });
      });
    });
    super.initState();
  }   
}
