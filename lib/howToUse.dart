import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';

import 'home.dart';

class HowToUse extends StatefulWidget {
  const HowToUse({Key? key}) : super(key: key);

  @override
  State<HowToUse> createState() => _HowToUseState();
}

class _HowToUseState extends State<HowToUse> {
  late DatabaseReference _messagesRef;

  Stream _getMessageStream() {
    return _messagesRef.orderByChild('timestamp').onValue;
  }

  AdmobBannerSize? bannerSize;

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref().child('howToUse');
    _initializeFirebase();
    bannerSize = AdmobBannerSize.BANNER;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text('Como Usar'),
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
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final text = message['text'] ?? '';
                        final imageUrl = message['image'];

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
                            ListTile(
                              title: Text(text),
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
