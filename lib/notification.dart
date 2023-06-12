import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';

class NativeNotify extends StatefulWidget {
  const NativeNotify({super.key});

  @override
  State<NativeNotify> createState() => _NativeNotifyState();
}

TextEditingController _textTitleNotficationEdtingController =
    TextEditingController();
TextEditingController _textMessageNotificationEdtingController =
    TextEditingController();

void sendPushNotification() async {
  final titleText = _textTitleNotficationEdtingController.text;
  final messageText = _textMessageNotificationEdtingController.text;

  final url =
      Uri.parse('https://app.nativenotify.com/api/flutter/notification');

  final Map<String, dynamic> requestBody = {
    'flutterAppId': '3041',
    'flutterAppToken': 'HWDbQQuPJhbNLGdph9aikH',
    'title': titleText,
    'body': messageText,
    'bigPictureURL': null,
    'data': 'teste de data',
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('Notificação enviada com sucesso!');
  } else {
    print(
        'Falha ao enviar a notificação. Código de status: ${response.statusCode}');
  }
}

class _NativeNotifyState extends State<NativeNotify> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() {
    setState(() {});
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing ",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notificação')),
      body: Container(
        child: ListView(
          children: [
            TextField(
              maxLines: null,
              controller: _textTitleNotficationEdtingController,
              decoration: InputDecoration(
                labelText: 'titulo da notificação',
              ),
            ),
            TextField(
              maxLines: null,
              controller: _textMessageNotificationEdtingController,
              decoration: InputDecoration(
                labelText: 'message',
              ),
            ),
            TextButton(onPressed: showNotification, child: Text('enviar'))
          ],
        ),
      ),
    );
  }
}
