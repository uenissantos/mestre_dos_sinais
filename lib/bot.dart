import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Messages',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelegramMessagesScreen(),
    );
  }
}

class TelegramMessagesScreen extends StatefulWidget {
  @override
  _TelegramMessagesScreenState createState() => _TelegramMessagesScreenState();
}

class _TelegramMessagesScreenState extends State<TelegramMessagesScreen> {
  String _lastMessage = 'Aguardando mensagem...';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    final token = ''; // Substitua pelo seu token de acesso à API do Telegram
    final chatId =
        '<id_do_grupo>'; // Substitua pelo ID do grupo do Telegram que você deseja receber mensagens

    final response = await http.get(
      Uri.parse('https://api.telegram.org/bot$token/getUpdates'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['ok']) {
        final result = data['result'];
        if (result.isNotEmpty) {
          final message = result.last['message']['text'];
          setState(() {
            _lastMessage = message;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Telegram Messages'),
      ),
      body: Center(
        child: Text(
          _lastMessage,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
