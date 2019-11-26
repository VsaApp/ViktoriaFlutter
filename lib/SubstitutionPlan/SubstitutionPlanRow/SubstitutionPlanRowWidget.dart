import 'package:flutter/material.dart';
import 'package:viktoriaflutter/Utils/Localizations.dart';

import 'package:viktoriaflutter/Utils/Models.dart';
import 'package:viktoriaflutter/Utils/SubjectRow.dart';

/// A row for one substitution
class SubstitutionPlanRow extends SubjectRow {
  // ignore: public_member_api_docs
  SubstitutionPlanRow({
    @required List<Substitution> substitutions,
    @required int index,
    @required BuildContext context,
    bool showUnit = true,
    Key key,
  }) : super(
            details: substitutions.map<SubjectRowDetails>((substitution) {
              return SubjectRowDetails(
                title: getTitle(substitution),
                subtitle: getInfoText(context, substitution),
                unit: substitution.unit,
                infoLeftTop: substitution.original.roomID,
                infoRightTop: substitution.original.teacherID.toUpperCase(),
                infoLeftBottom:
                    substitution.changed.roomID == substitution.original.roomID
                        ? ''
                        : substitution.changed.roomID,
                infoRightBottom: substitution.original.teacherID ==
                            substitution.changed.teacherID &&
                        !substitution.isExam
                    ? ''
                    : substitution.changed.teacherID.toUpperCase(),
              );
            }).toList(),
            index: index,
            showUnit: showUnit,
            topicColor: getColor(context, substitutions[index]),
            key: key);

  /// Returns the full substitution name
  static String getTitle(Substitution substitution) {
    return Data.subjects[substitution.original.subjectID.toUpperCase()] ??
        substitution.original.subjectID;
  }

  /// Returns the color of the substitution
  static Color getColor(BuildContext context, Substitution substitution) {
    return (substitution.color == null)
        ?
        // Default color
        Theme.of(context).primaryColor
        :
        // Changed color
        substitution.color;
  }

  /// Get the description of the substitution type
  static String getSubstitutionDescription(BuildContext context, int type) {
    switch (type) {
      case 0:
        return '';
      case 1:
        return AppLocalizations.of(context).freeLesson;
      case 2:
        return AppLocalizations.of(context).exam;
      default:
        return '';
    }
  }

  /// Get the substitution extra information text
  static String getInfoText(BuildContext context, Substitution substitution) {
    String info = '';
    final String description =
        getSubstitutionDescription(context, substitution.type);
    if (description.isNotEmpty) {
      info += description;
    } else if (substitution.changed.subjectID.isNotEmpty) {
      info += Data.subjects[substitution.changed.subjectID.toUpperCase()] ??
          substitution.changed.subjectID;
    }
    if (substitution.info.isNotEmpty) {
      if (info.isNotEmpty) {
        info += ': ';
      }
      info += substitution.info;
    }
    return info;
  }
}
