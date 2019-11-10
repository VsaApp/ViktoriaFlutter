import 'package:viktoriaflutter/Utils/Models/TimetableModel.dart';
import 'package:viktoriaflutter/Utils/Models/SubstitutionPlanModel.dart';

List<SubstitutionPlanDay> load(List<TimetableDay> _days, bool temp) {
  List<SubstitutionPlanDay> days = _days
      .where((day) => day.substitutionPlanForWeekday != '')
      .map((day) => day.getSubstitutionPlanDay())
      .toList();

  // Return or set the data in a static object...
  if (!(temp ?? false)) {
    days.sort((a, b) =>
        DateTime(int.parse(a.date.split('.')[2]),
            int.parse(a.date.split('.')[1]), int.parse(a.date.split('.')[0]))
            .compareTo(DateTime(int.parse(b.date.split('.')[2]),
            int.parse(b.date.split('.')[1]), int.parse(b.date.split('.')[0]))));
    SubstitutionPlan.days = days;
    return null;
  } else {
    return days;
  }
}

// Returns the static substitution plan...
List<SubstitutionPlanDay> getSubstitutionPlan() {
  return SubstitutionPlan.days;
}
