import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

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
      final response = await http.post(
        Uri.parse('http://localhost:5001/query'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': text,
        }),
      );

      var answer = _Message(text: "This is a simulated bot response.", isUser: false, isAnimated: true);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body) as Map<String, dynamic>;
        json['isUser'] = false;
        answer = _Message.fromJson(json)..isAnimated = true; // Set the animation flag
        print(answer);
      } else {
        throw Exception(response.body);
      }

      setState(() {
        _chatSessions[_currentChatIndex].add(answer);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Column(
        children: <Widget>[
          Expanded(
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
                      hintText: 'Message Poseidon-Bot',
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_controller.text),
                ),
              ],
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
  bool isAnimated;

  _Message({required this.text, required this.isUser, this.isAnimated = false});

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
            child: message.isAnimated
                ? DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'popin',
                    ),
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
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
