import 'package:flutter/material.dart';

class SendButton extends StatefulWidget {
  final void Function(String) onSubmitted;

  const SendButton({super.key, required this.onSubmitted});

  @override
  State<SendButton> createState() => SendButtonState();
}

class SendButtonState extends State<SendButton> {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textController,
              onSubmitted: handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Message Poseidon-Bot',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => handleSubmitted(textController.text),
            ),
          ),
        ],
      ),
    );
  }

  void handleSubmitted(String text) {
    widget.onSubmitted(text);
    textController.clear();
  }
}
