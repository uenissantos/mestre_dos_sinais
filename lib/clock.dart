
import 'dart:async';

import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  
  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  
  
  String _currentTime='';

  @override
  void initState() {

_startClock();
super.initState();
  }


  void _startClock (){
    
    Timer.periodic(Duration (seconds :1),(time) { 
      setState(() {
        
        _currentTime=DateTime.now().toString().substring(11,19);
      });
    });
    
  }
  
  
  @override
  Widget build(BuildContext context) {
    return  Container(
      child:
          Container(
            width: 80,
              color: Colors.white,
              child: Text(_currentTime,
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 18 ,fontWeight:FontWeight.bold,),
              )),

    );
  }
}
