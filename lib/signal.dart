import 'package:flutter/material.dart';
import 'package:mestre_dos_sinais/DateWidget.dart';
import 'package:mestre_dos_sinais/signalHistory.dart';

class Signal extends StatefulWidget {
  const Signal({Key? key}) : super(key: key);

  @override
  State<Signal> createState() => _SignalState();
}

class _SignalState extends State<Signal> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Container(child: DateWidget()),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: SignalHistory(),
      ),
    );
  }
}
