import 'package:flutter/material.dart';

import '../helper/Helper.dart';

class CheckInPage extends StatelessWidget {
  final String title;

  final Helper helper;

  CheckInPage({
    Key key,
    @required this.title,
    @required this.helper
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'checkin/checkin',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case 'checkin/checkin':
            builder = (BuildContext context) => Container();
            break;
          default:
            throw Exception('Invalid check in page route: ${settings.name}');
        }

        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
