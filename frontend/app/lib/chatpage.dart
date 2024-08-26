import 'dart:convert';
import 'package:app/homepage.dart';
import 'package:app/widgets/SlideFromRightPageRoute.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<_Chat> _chatSessions = [];
  int _currentChatIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    var chats = <_Chat>[];
    final response = await http.get(Uri.parse('http://localhost:5001/chats'),
     headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
        },);
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body) as List<dynamic>;
          for(var chat in json) {
            chats.add(_Chat.fromJson(chat));
          }
          setState(() {
            _chatSessions.clear();
            _chatSessions.addAll(chats);
          });
        } else {
          throw Exception(response.body);
        }
  }

Future<void> _handleSubmitted(String text) async {
  if (text.isEmpty) return;
  setState(() {
    _chatSessions[_currentChatIndex].messages.add(_Message(message: text, isUser: true, chatId: _chatSessions[_currentChatIndex].chat_id, id: "0"));
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
          'chat_id': _chatSessions[_currentChatIndex].chat_id,
        }),);
       var answer = _Message(message: "This is a simulated bot response.", isUser: false, chatId: "0", id:"0");
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          var json = jsonDecode(response.body) as Map<String, dynamic>;
          json['isUser'] = false;
          answer = _Message.fromJson(json);
          setState(() {
            // For now, simulate a bot response after a delay.
            _chatSessions[_currentChatIndex].messages.add(answer);
          });
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception(response.body);
        } 
    } catch (e) {
      print('Error: $e');
    }
    _controller.clear();

  _scrollToBottom();
}

  void _startNewChat() async {
    // setState(() async {
      final response = await http.post(Uri.parse('http://localhost:5001/chats'), 
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'chat_title': 'Chat ' + (_chatSessions.length+1).toString(),
          'user_id': 'asdf',
        }),);
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          var json = jsonDecode(response.body) as Map<String, dynamic>;
          var chat = _Chat.fromJson(json);
          _chatSessions.add(chat);
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          throw Exception(response.body);
        } setState(() {
      // For now, simulate a bot response after a delay.
    });
      _currentChatIndex = _chatSessions.length - 1;
    Navigator.pop(context); // Close the drawer
  }

   Future<void> handleDelete(String messageId) async {
    final response = await http.delete(Uri.parse('http://localhost:5001/messages/'), 
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message_id': messageId,
        }),
      );
        if (response.statusCode == 200) {
          print('Message deleted');
          _loadChats();
        } else {
          throw Exception(response.body);
        }
  }

Future<void> handleChatDelete(String chatId) async {
  if (_chatSessions.length > 1) {
    final response = await http.delete(Uri.parse('http://localhost:5001/chats/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'chat_id': chatId,
      }),
    );
    if (response.statusCode == 200) {
      print('Chat deleted');
      _loadChats(); // Reload the chats after deletion
    } else {
      throw Exception(response.body);
    }
  } else {
    print('Cannot delete the last remaining chat.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot delete the last remaining chat.')),
    );
  }
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
        actions: [
        IconButton(
          icon: const Icon(Icons.home),
          iconSize: 25,
          onPressed: () {
            Navigator.push(context, SlideFromRightPageRoute(widget: const MyHomePage(title:"Home")));
          },
          alignment: FractionalOffset.topRight,
        ),
      ],
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
                'All Chats',
                style: TextStyle(color: Color.fromARGB(192, 115, 115, 115), fontSize: 24),
              ),
            ),
            for (int i = 0; i < _chatSessions.length; i++)
              ListTile(
                title: Text( _chatSessions[i].title),
                onTap: () => _switchChat(i),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => handleChatDelete(_chatSessions[i].chat_id),
                ),
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
              itemCount: _chatSessions[_currentChatIndex].messages.length,
              itemBuilder: (context, index) {
                return Column (
                  children: [
                    _MessageWidget(
                      message: _chatSessions[_currentChatIndex].messages[index],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          _chatSessions[_currentChatIndex].messages[index].isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            icon: const Icon(Icons.delete),
                            iconSize: 25,
                            onPressed: () => handleDelete(_chatSessions[_currentChatIndex].messages[index].id),
                            alignment: _chatSessions[_currentChatIndex].messages[index].isUser ? FractionalOffset.topLeft : FractionalOffset.topRight,
                        ),
                      ),
                    ),
                    ],
                    ),
                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String message;
  final bool isUser;
  final String chatId;
  final String id;

  _Message({required this.message, required this.isUser, required this.chatId, required this.id});

  Map<String, dynamic> toJson() => {
        'message': message,
        'isUser': isUser,
        'chat_id': chatId,
      };

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        message: json['message'],
        chatId: json['chat_id'],
        isUser: json['typeOfMessage'] == 'user',
        id: json['id'],
      );
}

class _Chat {
  List<_Message> messages;
  String title;
  String owner_id;
  String chat_id;

  _Chat({required this.messages, required this.title, required this.owner_id, required this.chat_id});

  Map<String, dynamic> toJson() => {
        'messages': messages.map((msg) => msg.toJson()).toList(),
        'chat_title': title,
        'user_id': owner_id,
      };
  
  factory _Chat.fromJson(Map<String, dynamic> json) => _Chat(
        messages: json['messages'].map<_Message>((msg) => _Message.fromJson(msg)).toList(),
        title: json['title'],
        owner_id: json['owner_id'],
        chat_id: json['chat_id'],
      );
}

class _MessageWidget extends StatelessWidget {
  final _Message message;

  const _MessageWidget({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[Row(
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
              message.message,
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
    ]),
    );
  }
}
