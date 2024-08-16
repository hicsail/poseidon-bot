import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:animated_text_kit/animated_text_kit.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
>>>>>>> 9a5b422a18dcb054f2b04f4d761220761bc2577c

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

<<<<<<< HEAD
class ChatPageState extends State<ChatPage> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
    textController.addListener(updateIconOpacity);
  }

  @override
  void dispose() {
    textController.removeListener(updateIconOpacity);
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void updateIconOpacity() {
    setState(() {}); // Trigger a rebuild to update the icon opacity
  }

  bool get canSend => textController.text.isNotEmpty;

  void handleSubmitted(String text) {
    if (text.isEmpty) return;

    Duration speed;
    String botResponse = "This is a simulated bot response.";
      if (botResponse.length < 100) {
        speed = Duration(milliseconds: 50);
      } else {
        speed = Duration(milliseconds: 5);
      }

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      messages.add(ChatMessage(
        text: botResponse,
        isUser: false,
        isAnimated: true,
        animationSpeed: speed,
      ));
=======
class _ChatPageState extends State<ChatPage> {
  final List<List<_Message>> _chatSessions = [[]];
  int _currentChatIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatData = prefs.getString('chat_sessions');
    if (chatData != null) {
      final List<dynamic> decodedData = jsonDecode(chatData);
      setState(() {
        _chatSessions.clear();
        _chatSessions.addAll(decodedData.map((chat) => (chat as List<dynamic>).map((msg) => _Message.fromJson(msg)).toList()));
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatData = jsonEncode(_chatSessions.map((chat) => chat.map((msg) => msg.toJson()).toList()).toList());
    prefs.setString('chat_sessions', chatData);
  }

Future<void> _handleSubmitted(String text) async {
  if (text.isEmpty) return;
  setState(() {
    _chatSessions[_currentChatIndex].add(_Message(text: text, isUser: true));
  });
  _controller.clear();
  _scrollToBottom();

   try {
       final response = await http.post(Uri.parse('http://localhost:5001/query'), 
       headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': text,
        }),);
       var answer = _Message(text: "This is a simulated bot response.", isUser: false);
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          var json = jsonDecode(response.body) as Map<String, dynamic>;
          json['isUser'] = false;
          answer = _Message.fromJson(json);
          print(answer);
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception(response.body);
        } setState(() {
      // For now, simulate a bot response after a delay.
      _chatSessions[_currentChatIndex].add(answer);
>>>>>>> 9a5b422a18dcb054f2b04f4d761220761bc2577c
    });
    textController.clear();
    Future.delayed(Duration(milliseconds: 300), () {
      scrollToBottom();
    });
    focusNode.requestFocus();
    print(text);
    } catch (e) {
      print('Error: $e');
    }
    _controller.clear();

  _scrollToBottom();
  _saveChatHistory(); // Save the chat history after receiving the bot response
}

  void _startNewChat() {
    setState(() {
      _chatSessions.add([]);
      _currentChatIndex = _chatSessions.length - 1;
    });
    _saveChatHistory();
    Navigator.pop(context); // Close the drawer
  }

  void _switchChat(int index) {
    setState(() {
      _currentChatIndex = index;
    });
    Navigator.pop(context); // Close the drawer
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
    final messageBarHeight = 5.0;

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Poseidon-Bot'),
        backgroundColor: Color.fromARGB(255, 173, 232, 245),
=======
        backgroundColor: const Color.fromARGB(255, 173, 232, 245),
        title: const Text('Poseidon Bot', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 129, 241, 194),
              ),
              child: Text(
                'Past Chats',
                style: TextStyle(color: Color.fromARGB(192, 115, 115, 115), fontSize: 24),
              ),
            ),
            for (int i = 0; i < _chatSessions.length; i++)
              ListTile(
                title: Text('Chat ${i + 1}'),
                onTap: () => _switchChat(i),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: _startNewChat,
            ),
          ],
        ),
>>>>>>> 9a5b422a18dcb054f2b04f4d761220761bc2577c
      ),
      body: Column(
        children: <Widget>[
          Expanded(
<<<<<<< HEAD
            child: Padding(
              padding: EdgeInsets.only(bottom: messageBarHeight),
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(
                    message: messages[index],
                    onAnimationFinished: () {
                      if (!messages[index].isUser) {}
                    }
                    );
                },
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Message Poseidon-Bot',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Color.fromARGB(255, 173, 232, 245)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      maxLines: 8,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          handleSubmitted(text);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: AnimatedOpacity(
                      opacity: canSend ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_circle_up_sharp,
                          color: canSend ? Color.fromARGB(255, 173, 232, 245) : Colors.grey,
                        ),
                        iconSize: 40.0,
                        onPressed: canSend ? () {
                          handleSubmitted(textController.text);
                        } : null,
                        highlightColor: Color.fromARGB(255, 173, 232, 245),
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
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
  final Duration? animationSpeed;
  bool hasBeenAnimated;

  ChatMessage({required this.text, required this.isUser, this.isAnimated = false, this.animationSpeed, this.hasBeenAnimated = false});
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAnimationFinished;

  const ChatMessageWidget({required this.message, this.onAnimationFinished});

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
              child: Text(
                '🔱',
                style: TextStyle(fontSize: 20.0,),
                ),
              backgroundColor: Colors.transparent,
            ),
          if (!message.isUser) const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.grey[300] : Color.fromARGB(255, 173, 232, 245),
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
                    color: message.isUser ? Colors.white : Colors.black87,
                  ),
                )
                : AnimatedTextKit(
                  isRepeatingAnimation: false,
                  onFinished: () {
                    message.hasBeenAnimated = true;
                    if (onAnimationFinished != null) {
                      onAnimationFinished!();
                    }
                  },
                  animatedTexts: [
                    TyperAnimatedText(
                      message.text,
                      speed: message.animationSpeed ?? Duration(milliseconds: 50),
                    ),
                  ],
                ),
              )
            : Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.black87 : Colors.black87,
              ),
=======
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              controller: _scrollController,
              itemCount: _chatSessions[_currentChatIndex].length,
              itemBuilder: (context, index) {
                return _MessageWidget(
                  message: _chatSessions[_currentChatIndex][index],
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Type your message here...',
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_controller.text),
                ),
              ],
>>>>>>> 9a5b422a18dcb054f2b04f4d761220761bc2577c
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
      };

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        text: json['text'],
        isUser: json['isUser'],
      );
}

class _MessageWidget extends StatelessWidget {
  final _Message message;

  const _MessageWidget({required this.message});
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
              child: Text('AI'),
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
            child: Text(
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
