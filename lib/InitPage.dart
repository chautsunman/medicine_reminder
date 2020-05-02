import 'package:flutter/material.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
