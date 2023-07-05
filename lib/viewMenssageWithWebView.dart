import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mestre_dos_sinais/clock.dart';
import 'package:mestre_dos_sinais/signalHistory.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewMessageWithWebView extends StatefulWidget {
  const ViewMessageWithWebView({Key? key}) : super(key: key);

  @override
  State<ViewMessageWithWebView> createState() => _ViewMessageWithWebViewState();
}

class _ViewMessageWithWebViewState extends State<ViewMessageWithWebView> {
  // ignore: unused_field

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          Text('carregando');
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith(
              'https://bet7k.com/casino/1303-live-spaceman?ref=0a450b95e2b4&src=nmcfguhvpuuzhwotdlq&utm_source=84042&source_id=mygroup')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(
        'https://bet7k.com/casino/1303-live-spaceman?ref=0a450b95e2b4&src=nmcfguhvpuuzhwotdlq&utm_source=84042&source_id=mygroup'));

  Widget _buildMessagesList(Map<String, dynamic> messages) {
    final messageList = messages.entries.toList();
    messageList.sort((a, b) => a.key.compareTo(b.key));

    final lastMessageEntry = messageList.isNotEmpty ? messageList.last : null;
    if (lastMessageEntry != null) {
      final lastMessage = Map<String, dynamic>.from(lastMessageEntry.value);
      final lastText = lastMessage['text'] ?? '';
      final lastImageUrl = lastMessage['image'];

      return ListTile(
        title: Text(
          lastText,
          style: TextStyle(color: Colors.white),
        ),
        leading: lastImageUrl != null ? Image.network(lastImageUrl) : null,
      );
    } else {
      return SizedBox(); // Retorna um widget vazio se não houver mensagens
    }
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

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  void visibleClockToWebView() {
    setState(() {
      clockVisible = !clockVisible;
    });
  }

  void viewList() {
    setState(() {
      listVisible
          ? nameButtonList = 'ver lista'
          : nameButtonList = 'fechar lista';

      listVisible = !listVisible;
    });
  }

  String nameButtonList = 'ver Lista';

  Icon? iconClock;

  changeIconClock() {
    iconClock = clockVisible
        ? Icon(
            Icons.close,
            weight: 20,
            color: Colors.red,
          )
        : Icon(
            Icons.lock_clock,
            weight: 20,
            color: Colors.white,
          );
    return iconClock;
  }

  bool clockVisible = true;
  bool listVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Center(
            child: _bannerAd != null
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  )
                : Container(
                    child: Text('sem anuncios'),
                  ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          Positioned(
              top: 26,
              right: 16,
              child: Container(
                child: Row(
                  children: [
                    Visibility(visible: clockVisible, child: Clock()),
                    IconButton(
                      onPressed: () {
                        visibleClockToWebView();
                      },
                      icon: changeIconClock(),
                    ),
                    TextButton(
                      onPressed: () {
                        viewList();
                      },
                      child: Text(
                        nameButtonList,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
            top: 56,
            bottom: 0,
            left: 0,
            right: 70,
            child: Visibility(
                visible: listVisible,
                child: Container(
                    width: double.infinity,
                    child: SignalHistory(),
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
