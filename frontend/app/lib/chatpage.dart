import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final List<ChatMessage> messages = []; // List to store chat messages
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      messages.add(ChatMessage(
        text: "This is a simulated bot response.",
        isUser: false,
        isAnimated: true,
      ));
    });
    textController.clear();
    scrollToBottom();
    focusNode.requestFocus();
    print(text);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageBarHeight = 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: messageBarHeight),
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(message: messages[index]);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Message Poseidon-Bot',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => handleSubmitted(textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isAnimated;
  bool hasBeenAnimated;

  ChatMessage({required this.text, required this.isUser, this.isAnimated = false, this.hasBeenAnimated = false});
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser)
            const CircleAvatar(
              child: Text('P-Bot'),
              backgroundColor: Colors.grey,
            ),
          if (!message.isUser) const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: message.isAnimated
              ? DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'popin',
                ),
                child: message.hasBeenAnimated
                ? Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87
                  ),
                )
                : AnimatedTextKit(
                  isRepeatingAnimation: false,
                  onFinished: () {
                    message.hasBeenAnimated = true;
                  },
                  animatedTexts: [
                    TyperAnimatedText(
                      message.text,
                      speed: Duration(milliseconds: 50),
                    ),
                  ],
                ),
              )
            : Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8.0),
          if (message.isUser)
            const CircleAvatar(
              child: Text('U'),
              backgroundColor: Colors.blueAccent,
            ),
        ],
      ),
    );
  }
}
