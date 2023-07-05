import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mestre_dos_sinais/inputs.dart';
import 'package:url_launcher/url_launcher.dart';

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

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final adUnitIdB = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitIdB,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Chamado quando um anúncio é recebido com sucesso..
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Chamado quando uma solicitação de anúncio falhou.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
// Chamado quando um anúncio abre uma sobreposição que cobre a tela.        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        // Chamado quando ocorre uma impressão no anúncio.
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    loadAd();
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref().child('sinais');
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

/*   void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  } */

  Future<void> _launchUrl(url) async {
    final Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(child: InputSignal()),
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
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final text = message['text'] ?? '';

                    final imageUrl = message['image'];
                    final isGreen = text.toLowerCase().contains('GREENS');
                    final isRed = text.toLowerCase().contains('Reds');
                    final isUrl = text.toLowerCase().contains('https://');

                    return Column(
                      children: [
                        isUrl
                            ? TextButton(
                                onPressed: () {
                                  _launchUrl(text);
                                },
                                child: Text(
                                  'ENTRAR AGORA',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue),
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    )),
                              )
                            : Container(
                                child: ListTile(
                                  title: Container(
                                    child: isGreen
                                        ? Text(
                                            text,
                                            style: TextStyle(
                                                color: isGreen
                                                    ? Colors.green
                                                    : isRed
                                                        ? Colors.red
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Text(
                                            text,
                                            style: TextStyle(
                                                color: isGreen
                                                    ? Colors.green
                                                    : isRed
                                                        ? Colors.red
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ),
                        Container(
                          child:
                              imageUrl != null ? Image.network(imageUrl) : null,
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
        if (_bannerAd != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
      ],
    );
  }
}
