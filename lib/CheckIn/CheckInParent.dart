import 'package:flutter/material.dart';

import 'CheckInRecord.dart';
import 'CheckIn.dart';

import '../helper/Helper.dart';

class CheckInParent extends StatelessWidget {
  final String title;

  final Helper helper;

  CheckInParent({
    Key key,
    @required this.title,
    @required this.helper
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'checkin/checkinRecord',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case 'checkin/checkinRecord':
            return MaterialPageRoute(
              builder: (BuildContext context) => CheckInRecord(
                title: title,
                helper: helper,
              ),
              settings: settings
            );
            break;
          case 'checkin/checkin':
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => CheckIn(
                helper: helper,
              ),
              settings: settings
            );
            break;
          default:
            throw Exception('Invalid check in page route: ${settings.name}');
        }
      },
    );
  }
}
