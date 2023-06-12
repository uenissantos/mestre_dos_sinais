import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

class SignalHistory extends StatefulWidget {
  const SignalHistory({Key? key}) : super(key: key);

  @override
  State<SignalHistory> createState() => _SignalHistoryState();
}

class _SignalHistoryState extends State<SignalHistory> {
  late DatabaseReference _messagesRef;

  Stream _getMessageStream() {
    return _messagesRef.orderByChild('timestamp').onValue;
  }

  AdmobBannerSize? bannerSize;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref().child('sinais');
    _initializeFirebase();
    bannerSize = AdmobBannerSize.BANNER;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
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

  Future<void> _launchUrl(url) async {
    final Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
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
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final text = message['text'] ?? '';
                        final imageUrl = message['image'];
                        final isGreen = text.toLowerCase().contains('green');
                        final isRed = text.toLowerCase().contains('red');
                        final isUrl = text.toLowerCase().contains('https://');

                        if (index != 0 && index % 6 == 0) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20.0, top: 20),
                            child: AdmobBanner(
                              adUnitId: getBannerAdUnitId()!,
                              adSize: bannerSize!,
                              listener: (AdmobAdEvent event,
                                  Map<String, dynamic>? args) {},
                              onBannerCreated:
                                  (AdmobBannerController controller) {},
                            ),
                          );
                        }

                        return Column(
                          children: [
                            isUrl
                                ? TextButton(
                                    onPressed: () {
                                      _launchUrl(text);
                                    },
                                    child: Text(text))
                                : Container(
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
            Container(
              margin: EdgeInsets.only(bottom: 20.0, top: 20),
              child: AdmobBanner(
                adUnitId: getBannerAdUnitId()!,
                adSize: bannerSize!,
                listener: (AdmobAdEvent event, Map<String, dynamic>? args) {},
                onBannerCreated: (AdmobBannerController controller) {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
