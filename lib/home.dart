import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mestre_dos_sinais/ENVIO/sendHowToUse.dart';
import 'package:mestre_dos_sinais/ENVIO/sendLiveOn.dart';
import 'package:mestre_dos_sinais/ENVIO/sendSinais.dart';
import 'package:mestre_dos_sinais/howToUse.dart';
import 'package:mestre_dos_sinais/signalHistory.dart';
import 'package:mestre_dos_sinais/viewMenssageWithWebView.dart';

import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AdmobBannerSize? bannerSize;
  late AdmobInterstitial interstitialAd;
  late AdmobReward rewardAd;

  @override
  void initState() {
    bannerSize = AdmobBannerSize.LARGE_BANNER;
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );

    rewardAd = AdmobReward(
      adUnitId: getRewardBasedVideoAdUnitId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) rewardAd.load();
      },
    );

    interstitialAd.load();
    rewardAd.load();

    super.initState();
  }

  void showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    final Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' ajude a manter o app ativo',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.coffee),
          onPressed: () async {
            if (await rewardAd.isLoaded) {
              rewardAd.show();
            } else {
              showSnackBar('Reward ad is still loading...');
            }
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clock(),
                // Image.asset('assets/spaceman.png'),

                const SizedBox(height: 30),

                CustomButton(
                  text: 'Live',
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const ViewMessageWithWebView();
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: ' Sinais ',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () async {
                    // final isLoaded = await interstitialAd.isLoaded;
                    // if (isLoaded ?? false) {
                    //   interstitialAd.show();
                    // } else {
                    //   showSnackBar('Interstitial ad is still loading...');
                    // }

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const SignalHistory();
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: ' modo de usar ',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return HowToUse();
                      }),
                    );
                  },
                ),

                const SizedBox(height: 50),
                CustomButton(
                  text: ' enviar na live ',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return SendLiveOn();
                      }),
                    );
                  },
                ),

                const SizedBox(height: 10),
                CustomButton(
                  text: ' enviar sinais',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return SendSinais();
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: ' enviar modo  de usar ',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return SendHowToUse();
                      }),
                    );
                  },
                ),
                // const SizedBox(height: 10),
                //       Container(
                //   margin: EdgeInsets.only(bottom: 20.0, top: 20),
                //   child: AdmobBanner(
                //     adUnitId: getBannerAdUnitId()!,
                //     adSize: bannerSize!,
                //     listener:
                //         (AdmobAdEvent event, Map<String, dynamic>? args) {},
                //     onBannerCreated: (AdmobBannerController controller) {},
                //   ),
                // ),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      _launchUrl(
                          'https://privacypolicespaceman.blogspot.com/2023/06/privacy-policy-uenis-de-jesus-santos.html');
                    },
                    child: Text('POLITICA DE PRIVACIDADE')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    interstitialAd.dispose();
    rewardAd.dispose();
    super.dispose();
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// ids validos para publicação
// String? getBannerAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/2934735716';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-1005929281486446/78413559450';
//   }
//   return null;
// }
//
// String? getInterstitialAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/4411468910';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-1005929281486446/73186117640';
//   }
//   return null;
// }
//
// String? getRewardBasedVideoAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/1712485313';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-1005929281486446/70750691850';
//   }
//   return null;
// }

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/1033173712';
  }
  return null;
}

String? getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/1712485313';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/5224354917';
  }
  return null;
}
