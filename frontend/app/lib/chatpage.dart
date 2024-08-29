import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:app/settingspage.dart';
import 'dart:convert';
import 'package:app/homepage.dart';
import 'package:app/widgets/SlideFromRightPageRoute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const MainColor = Color.fromARGB(255, 173, 232, 245);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final List<_Chat> _chatSessions = [];
  int _currentChatIndex = 0;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadChats();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
    textController.addListener(updateIconOpacity);

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    textController.removeListener(updateIconOpacity);
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void updateIconOpacity() {
    setState(() {}); // Trigger a rebuild to update the icon opacity
  }

  bool get canSend => textController.text.isNotEmpty;

  Future<void> _loadChats() async {
    var chats = <_Chat>[];
    final response = await http.get(
      Uri.parse('http://localhost:5001/chats'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as List<dynamic>;
      for (var chat in json) {
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

  void handleSubmitted(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _chatSessions[_currentChatIndex].messages.add(_Message(
        message: text,
        isUser: true,
        chatId: _chatSessions[_currentChatIndex].chat_id,
        id: "0",
      ));
    });

    textController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/query'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': text,
          'chat_id': _chatSessions[_currentChatIndex].chat_id,
        }),
      );

      var answer = _Message(
        message: "This is a simulated bot response.",
        isUser: false,
        chatId: "0",
        id: "0",
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body) as Map<String, dynamic>;
        json['isUser'] = false;
        answer = _Message.fromJson(json);

        setState(() {
          _chatSessions[_currentChatIndex].messages.add(answer);
        });
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void toggleMenu() {
    setState(() {
      if (isMenuOpen) {
        controller.reverse();
      } else {
        controller.forward();
      }
      isMenuOpen = !isMenuOpen;
    });
  }

  void _startNewChat() async {
    final response = await http.post(
      Uri.parse('http://localhost:5001/chats'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'chat_title': 'Chat ' + (_chatSessions.length + 1).toString(),
        'user_id': 'asdf',
      }),
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      var chat = _Chat.fromJson(json);

      setState(() {
        _chatSessions.add(chat);
        _currentChatIndex = _chatSessions.length - 1;
      });
    } else {
      throw Exception(response.body);
    }

    Navigator.pop(context); // Close the drawer
  }

  Future<void> handleDelete(String messageId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5001/messages/'),
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
      final response = await http.delete(
        Uri.parse('http://localhost:5001/chats/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'chat_id': chatId,
        }),
      );

      if (response.statusCode == 200) {
        print('Chat deleted');
        _loadChats();
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

  @override
  Widget build(BuildContext context) {
    final messageBarHeight = 5.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor,
        title: const Text('Poseidon Bot', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            iconSize: 25,
            onPressed: () {
              Navigator.push(
                context,
                SlideFromRightPageRoute(widget: const MyHomePage(title: "Home")),
              );
            },
            alignment: FractionalOffset.topRight,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleMenu,
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
                style: TextStyle(
                  color: Color.fromARGB(192, 115, 115, 115),
                  fontSize: 24,
                ),
              ),
            ),
            for (int i = 0; i < _chatSessions.length; i++)
              ListTile(
                title: Text(_chatSessions[i].title),
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
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: messageBarHeight),
                child: ListView.builder(
  controller: scrollController,
  padding: const EdgeInsets.all(8.0),
  itemCount: _chatSessions[_currentChatIndex].messages.length,
  itemBuilder: (context, index) {
    final isNewest = index == _chatSessions[_currentChatIndex].messages.length - 1 &&
                     !_chatSessions[_currentChatIndex].messages[index].isUser;
                     
    return Column(
      children: [
        _MessageWidget(
          message: _chatSessions[_currentChatIndex].messages[index],
          isNewest: isNewest,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: _chatSessions[_currentChatIndex].messages[index].isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 25,
                  onPressed: () => handleDelete(
                    _chatSessions[_currentChatIndex].messages[index].id
                  ),
                  alignment: _chatSessions[_currentChatIndex].messages[index].isUser
                      ? FractionalOffset.topLeft
                      : FractionalOffset.topRight,
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
                              borderSide: BorderSide(color: MainColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                              color: canSend ? MainColor : Colors.grey,
                            ),
                            iconSize: 40.0,
                            onPressed: canSend
                                ? () {
                                    handleSubmitted(textController.text);
                                  }
                                : null,
                            highlightColor: MainColor,
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
          SlideTransition(
            position: slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 1 / 3,
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Menu',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                    // Add more menu items here
                  ],
                ),
              ),
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
  bool hasAnimated;

  _Message({
    required this.message,
    required this.isUser,
    required this.chatId,
    required this.id,
    this.hasAnimated = false,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'isUser': isUser,
        'chat_id': chatId,
        'hasAnimated': hasAnimated,
      };

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        message: json['message'],
        chatId: json['chat_id'],
        isUser: json['typeOfMessage'] == 'user',
        id: json['id'],
        hasAnimated: json['hasAnimated'] ?? false,
      );
}


class _Chat {
  List<_Message> messages;
  String title;
  String owner_id;
  String chat_id;

  _Chat(
      {required this.messages,
      required this.title,
      required this.owner_id,
      required this.chat_id});

  Map<String, dynamic> toJson() => {
        'messages': messages.map((msg) => msg.toJson()).toList(),
        'chat_title': title,
        'user_id': owner_id,
      };

  factory _Chat.fromJson(Map<String, dynamic> json) => _Chat(
        messages: json['messages']
            .map<_Message>((msg) => _Message.fromJson(msg))
            .toList(),
        title: json['title'],
        owner_id: json['owner_id'],
        chat_id: json['chat_id'],
      );
}
class _MessageWidget extends StatelessWidget {
  final _Message message;
  final bool isNewest;

  const _MessageWidget({required this.message, required this.isNewest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              if (!message.isUser)
                const CircleAvatar(
                  child: Text('🔱'),
                  backgroundColor: Colors.transparent,
                ),
              if (!message.isUser) const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color:
                      message.isUser ?   Colors.grey[300]: MainColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: message.isUser
                    ? Text(
                        message.message,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black87,
                        ),
                      )
                    : isNewest && !message.hasAnimated
                        ? AnimatedTextKit(
                            isRepeatingAnimation: false,
                            animatedTexts: [
                              TyperAnimatedText(
                                message.message,
                                textStyle: const TextStyle(
                                  color: Colors.black87,
                                ),
                                speed: const Duration(milliseconds: 10),
                              ),
                            ],
                            onFinished: () {
                              // Mark the message as having been animated
                              message.hasAnimated = true;
                            },
                          )
                        : Text(
                            message.message,
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
              ),
              if (message.isUser) const SizedBox(width: 8.0),
              // if (message.isUser)
              //   const CircleAvatar(
              //     child: Text('U'),
              //     backgroundColor: Colors.blueAccent,
              //   ),
            ],
          ),
        ],
      ),
    );
  }
}
