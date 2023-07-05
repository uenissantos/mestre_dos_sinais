import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatefulWidget {
  @override
  _DateWidgetState createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    getCurrentDate();
  }

  void getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('dd/MM/yyyy');
    setState(() {
      currentDate = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Lista do dia: $currentDate',
      style: TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}
