import 'package:flutter/material.dart';
import 'widgets/SendButton.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

void handleSubmitted(String text) {
  print("$text");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Expanded(
            child: Center(
            child: Text(
              'This is the chat page',
              ),
            ),
          ),
          SendButton(onSubmitted: handleSubmitted),
        ],
      ),
    );
  }
}