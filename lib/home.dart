import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mestre_dos_sinais/signal.dart';

import 'package:mestre_dos_sinais/viewMenssageWithWebView.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

import 'clock.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // AdmobBannerSize? bannerSize;
  // late AdmobInterstitial interstitialAd;
  // late AdmobReward rewardAd;
  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      // Permissão concedida
      print('Permissão de notificação concedida');
    } else {
      // Permissão negada
      print('Permissão de notificação negada');
    }
  }

  RewardedAd? _rewardedAd;

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final adUnitIdB = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitIdB,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
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

  final adUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Substitua pelo seu ID de bloco de anúncios
  bool _adLoaded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadAd();
    // Carrega o anúncio premiado
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _adLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print('Falha ao carregar o anúncio: $error');
        },
      ),
    );
  }

  void showRewardedAd(param) {
    if (!_adLoaded) {
      print('O anúncio ainda não foi carregado.');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Atenção !'),
            content: const Text(
                '  assistir todo o anuncio ajuda a manter a lista funcionando'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
        ad.dispose(); // Descarta o anúncio após ser dispensado
        _loadRewardedAd(); // Carrega o anúncio novamente quando o usuário retornar
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose(); // Descarta o anúncio se falhar em exibir o conteúdo em tela cheia
        _loadRewardedAd(); // Carrega o anúncio novamente quando o usuário retornar
      },
      onAdImpression: (ad) {},
      onAdClicked: (ad) {},
    );

    _rewardedAd!.setImmersiveMode(true);

    _rewardedAd!.show(
      onUserEarnedReward: (ad, rewardItem) {
        // Lógica para recompensar o usuário por assistir ao anúncio

        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return param == 'sinais' ? Signal() : ViewMessageWithWebView();
          }),
        );
        print(
            'Usuário ganhou a recompensa: ${rewardItem.amount} ${rewardItem.type}');
        _timer = Timer(const Duration(seconds: 5), () {
          if (_rewardedAd != null && _adLoaded) {
            _rewardedAd!.dispose();
            _loadRewardedAd();
          }
        });
      },
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _adLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print('Falha ao carregar o anúncio: $error');
        },
      ),
    );
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
        title: Center(
          child: const Text(
            ' Mestre dos sinais',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Clock(),
                Image.asset(
                  'assets/spaceman.png',
                ),
                const SizedBox(height: 15),
                CustomButton(
                  text: 'JOGAR',
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () async {
/*                     showRewardedAd('jogar');
 */

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return ViewMessageWithWebView();
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: ' SINAIS ',
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () async {
/*                     showRewardedAd('sinais');

 */

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext context) {
                        return Signal();
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
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

  // @override
  // void dispose() {
  //   interstitialAd.dispose();
  //   rewardAd.dispose();
  //   super.dispose();
  // }
  @override
  void dispose() {
    _rewardedAd?.dispose();
    _timer?.cancel();
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
//     return 'ca-app-pub-1005929281486446/7841355945';
//   }
//   return null;
// }
//
// String? getInterstitialAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/4411468910';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-1005929281486446/7318611764';
//   }
//   return null;
// }
//
// String? getRewardBasedVideoAdUnitId() {
//   if (Platform.isIOS) {
//     return 'ca-app-pub-3940256099942544/1712485313';
//   } else if (Platform.isAndroid) {
//     return 'ca-app-pub-1005929281486446/7075069185';
//   }
//   return null;
// }
// ID TESTE
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
