// ignore_for_file: unused_field

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class SendSinais extends StatefulWidget {
  const SendSinais({Key? key}) : super(key: key);

  @override
  State<SendSinais> createState() => _SendSinaisState();
}

class _SendSinaisState extends State<SendSinais> {
  late DatabaseReference _messagesRef;
  TextEditingController _textEditingController = TextEditingController();
  List<String> _imageUrls = [];
  bool _uploadingImage = false;

  Stream _getMessageStream() {
    return _messagesRef.orderByChild('timestamp').onValue;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.reference().child('sinais');
    _initializeFirebase();

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

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _uploadingImage = true;
      });

      try {
        final imageFile = File(pickedImage.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});

        if (snapshot.state == TaskState.success) {
          final imageUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            _imageUrls.add(imageUrl);
          });
        } else {
          print('Error uploading image');
        }
      } catch (error) {
        print('Error uploading image: $error');
      }

      setState(() {
        _uploadingImage = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _textEditingController.text;
    if (messageText.isEmpty && _imageUrls.isEmpty) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (_imageUrls.isNotEmpty) {
      for (final imageUrl in _imageUrls) {
        _messagesRef.push().set({
          'text': messageText,
          'image': imageUrl,
          'timestamp': currentTime, // Adiciona o campo de timestamp
        });
      }
    } else {
      _messagesRef.push().set({
        'text': messageText,
        'timestamp': currentTime, // Adiciona o campo de timestamp
      });
    }

    setState(() {
      _textEditingController.clear();
      _imageUrls.clear();
    });
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri url0 = Uri.parse(url);

    if (!await canLaunchUrl(url0)) {
      throw Exception('Could not launch $url0');
    } else {
      await launch(url0.toString());
    }
  }

  void showNotification(String title) {
    flutterLocalNotificationsPlugin.show(
        0,
        'mestre dos sinais',
        title,
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text('Sinais'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _getMessageStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = <Map<String, dynamic>>[];

                    final snapshotValue = snapshot.data!.snapshot.value;
                    if (snapshotValue != null) {
                      snapshotValue.forEach((key, value) {
                        final message = Map<String, dynamic>.from(value);
                        messages.add(message);
                      });
                    }
                    messages.sort((a, b) {
                      final timestampA = a['timestamp'];
                      final timestampB = b['timestamp'];
                      return timestampA.compareTo(timestampB);
                    });

                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final text = message['text'] ?? '';
                        final imageUrl = message['image'];
                        final isGreen = text.toLowerCase().contains('green');
                        final isRed = text.toLowerCase().contains('red');
                        final isUrl = text.toLowerCase().contains('https://');
                        showNotification(text);
                        return Column(
                          children: [
                            if (isUrl)
                              TextButton(
                                onPressed: () => _launchUrl(text),
                                child: Text(text),
                              ),
                            if (text.isNotEmpty)
                              Container(
                                child: ListTile(
                                  title: Text(
                                    text,
                                    style: TextStyle(
                                      color: isGreen
                                          ? Colors.green
                                          : isRed
                                              ? Colors.red
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            Container(
                              child: imageUrl != null
                                  ? Image.network(imageUrl)
                                  : null,
                              width: 250,
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No messages'));
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  maxLines: null,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: 'Text',
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendMessage(),
                  child: Text('Add Message'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Add Image'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
