import 'package:flutter/material.dart';

import 'Reminder.dart';
import 'DetailsPage.dart';

import 'Helper.dart';

import 'obj/MedicationObj.dart';

class ReminderPage extends StatelessWidget {
  final String title;

  final Helper helper;

  ReminderPage({
    Key key,
    @required this.title,
    @required this.helper
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'reminder/reminder',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case 'reminder/reminder':
            builder = (BuildContext context) => Reminder(
              title: title,
              helper: helper,
            );
            break;
          case 'reminder/details':
            builder = (BuildContext context) {
              final MedicationObj medication = settings.arguments;

              return DetailsPage(
                medication: medication,
                helper: helper,
              );
            };
            break;
          default:
            throw Exception('Invalid reminder page route: ${settings.name}');
        }

        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
