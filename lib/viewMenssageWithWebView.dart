import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mestre_dos_sinais/clock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home.dart';


class ViewMessageWithWebView extends StatefulWidget {
  const ViewMessageWithWebView({Key? key}) : super(key: key);

  @override
  State<ViewMessageWithWebView> createState() => _ViewMessageWithWebViewState();
}

class _ViewMessageWithWebViewState extends State<ViewMessageWithWebView> {
  late DatabaseReference _messagesRef;
  bool _hasnewMessage = false;
  Timer? _messageTimer;
  AdmobBannerSize? bannerSize;
bool clockVisible=true;
  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref().child('liveOn');
    _messagesRef.onChildAdded.listen((event) {
      setState(() {
        _hasnewMessage = true;
      });
      _startMessageTimer();
    });


 bannerSize = AdmobBannerSize.BANNER;

  }

  void _startMessageTimer() {
    _messageTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        _hasnewMessage = false;
      });
    });
  }


  void  visibleClockToWebView (){


    setState(() {
      clockVisible = !clockVisible;

    });

  }

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
          if (request.url.startsWith('https://playpix.com/affiliates/?btag=1160902_l177491')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://playpix.com/affiliates/?btag=1160902_l177491'));

  Widget _buildMessagesList(Map<String, dynamic> messages) {
    final messageList = messages.entries.toList();
    messageList.sort((a, b) => a.key.compareTo(b.key));

    final lastMessageEntry = messageList.isNotEmpty ? messageList.last : null;
    if (lastMessageEntry != null) {
      final lastMessage = Map<String, dynamic>.from(lastMessageEntry.value);
      final lastText = lastMessage['text'] ?? '';
      final lastImageUrl = lastMessage['image'];

      return ListTile(
        title: Text(lastText,style: TextStyle(color: Colors.white),),
        leading: lastImageUrl != null ? Image.network(lastImageUrl) : null,
      );
    } else {
      return SizedBox(); // Retorna um widget vazio se não houver mensagens
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

   Icon? iconClock ;

   changeIconClock(){

  iconClock =clockVisible? Icon(Icons.close, weight: 20,color: Colors.red,):Icon(Icons.lock_clock, weight: 20, color: Colors.blue,);
return iconClock;
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
    AppBar(
          title: Container(
            width:double.infinity,
            child:  FittedBox(
              fit: BoxFit.contain,
              child: AdmobBanner(

                  adUnitId: getBannerAdUnitId()!,
                  adSize: bannerSize!,
                  listener: (AdmobAdEvent event,
                      Map<String, dynamic>? args) {
                  },
                  onBannerCreated:
                      (AdmobBannerController controller) {
                    // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                    // Normally you don't need to worry about disposing this yourself, it's handled.
                    // If you need direct access to dispose, this is your guy!
                    // controller.dispose();
                  },
                ),
            ),

          ),
        ),


      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: _hasnewMessage,
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  color: Colors
                      .blueGrey, // Define a cor de fundo do container da mensagem
                  padding: EdgeInsets.all(16.0),
                  child: StreamBuilder(
                    stream: _messagesRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        final dynamic snapshotValue =
                            snapshot.data!.snapshot.value;
                        final messages = Map<String, dynamic>.from(
                            snapshotValue as Map<dynamic, dynamic>);
                        return _buildMessagesList(messages);
                      } else {
                        return Center(child: Text('Live Offline'));
                      }
                    },
                  ),
                ),
              ),
            ),
          ),



  Positioned(
    top: 26,
    right: 16,
    child: Container(
      child:Row(
        children: [
          Visibility(
              visible: clockVisible,
              child: Clock()

          ),
          IconButton(onPressed: (){
            visibleClockToWebView();

          }, icon:changeIconClock(),


          )
        ],
      ),)),

        ],
      ),
    );
  }
}
