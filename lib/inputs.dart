import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InputSignal extends StatefulWidget {
  const InputSignal({Key? key}) : super(key: key);

  @override
  State<InputSignal> createState() => _InputSignalState();
}

class _InputSignalState extends State<InputSignal> {
  late DatabaseReference _messagesRef;
  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref().child('input');
    _messagesRef.onChildAdded.listen((event) {});
  }

  Widget _buildMessagesList(Map<String, dynamic> messages) {
    final messageList = messages.entries.toList();
    messageList.sort((a, b) => a.key.compareTo(b.key));

    final lastMessageEntry = messageList.isNotEmpty ? messageList.last : null;
    if (lastMessageEntry != null) {
      final lastMessage = Map<String, dynamic>.from(lastMessageEntry.value);
      final prohibited = lastMessage['entrada'] ?? '0';
      final green = lastMessage['green'] ?? '0';
      final red = lastMessage['green'] ?? '0';

      return Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '🚀 Entradas: $prohibited ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '✅ Greens: $green',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '✖️ Reds: $red',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return SizedBox(); // Retorna um widget vazio se não houver mensagens
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: StreamBuilder(
        stream: _messagesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final dynamic snapshotValue = snapshot.data!.snapshot.value;
            final messages = Map<String, dynamic>.from(
                snapshotValue as Map<dynamic, dynamic>);
            return _buildMessagesList(messages);
          } else {
            return Center(child: Text('Live Offline'));
          }
        },
      ),
    );
  }
}
