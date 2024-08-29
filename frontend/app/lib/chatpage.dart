import 'dart:convert';
import 'package:app/homepage.dart';
import 'package:app/widgets/SlideFromRightPageRoute.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/settingspage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

const MainColor = Color.fromARGB(255, 173, 232, 245);

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final List<_Chat> _chatSessions = [];
  int _currentChatIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
    _controller.addListener(updateIconOpacity);

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
    _controller.removeListener(updateIconOpacity);
    _controller.dispose();
    focusNode.dispose();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    final response = await http.get(
      Uri.parse('http://localhost:5001/chats'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as List<dynamic>;
      final chats = json.map((chat) => _Chat.fromJson(chat)).toList();
      setState(() {
        _chatSessions
          ..clear()
          ..addAll(chats);
      });
    } else {
      throw Exception(response.body);
    }
  }

  void updateIconOpacity() {
    setState(() {}); // Trigger a rebuild to update the icon opacity
  }

  bool get canSend => _controller.text.isNotEmpty;

  Future<void> _handleSubmitted(String text) async {
    if (text.isEmpty || _chatSessions.isEmpty) return;
    setState(() {
      _chatSessions[_currentChatIndex].messages.add(
        _Message(
          message: text,
          isUser: true,
          chatId: _chatSessions[_currentChatIndex].chat_id,
          id: "0",
        ),
      );
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
        final json = jsonDecode(response.body) as Map<String, dynamic>;
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
    _controller.clear();
    focusNode.requestFocus();

    _scrollToBottom();
  }

  Future<void> _startNewChat() async {
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
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final chat = _Chat.fromJson(json);
      setState(() {
        _chatSessions
          ..add(chat)
          ..length;
        _currentChatIndex = _chatSessions.length - 1;
      });
      Navigator.pop(context); // Close the drawer
    } else {
      throw Exception(response.body);
    }
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final messageBarHeight = 60.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor,
        title: const Text(
          'Poseidon Bot',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleMenu,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            iconSize: 25,
            onPressed: () {
              Navigator.push(
                context,
                SlideFromRightPageRoute(widget: const MyHomePage(title: "Home")),
              );
            },
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
            if (_chatSessions.isNotEmpty)
              ...List.generate(_chatSessions.length, (i) {
                return ListTile(
                  title: Text(_chatSessions[i].title),
                  onTap: () => _switchChat(i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => handleChatDelete(_chatSessions[i].chat_id),
                  ),
                );
              }),
            if (_chatSessions.isEmpty)
              const Center(
                child: Text('No chat sessions available'),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: _startNewChat,
            ),
          ],
        ),
      ),
      body: _chatSessions.isNotEmpty
          ? Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _chatSessions[_currentChatIndex].messages.length,
                          itemBuilder: (context, index) {
                            final message = _chatSessions[_currentChatIndex].messages[index];
                            return _MessageWidget(
                              message: message,
                              onDelete: () => handleDelete(message.id),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: messageBarHeight,
                      color: MainColor,
                      child: _buildMessageInput(),
                    ),
                  ],
                ),
                SlideTransition(
                  position: slideAnimation,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    color: Colors.grey[200],
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          title: const Text('Settings'),
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideFromRightPageRoute(widget: const SettingsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('No chat sessions available'),
            ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _controller,
              focusNode: focusNode,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: canSend && _chatSessions.isNotEmpty ? () => _handleSubmitted(_controller.text) : null,
        ),
      ],
    );
  }
}

class _Message {
  final String id;
  final String message;
  final bool isUser;
  final String chatId;

  _Message({
    required this.message,
    required this.isUser,
    required this.chatId,
    required this.id,
  });

  factory _Message.fromJson(Map<String, dynamic> json) {
    return _Message(
      id: json['id'],
      message: json['message'],
      isUser: json['isUser'],
      chatId: json['chat_id'],
    );
  }
}

class _Chat {
  final String chat_id;
  final String title;
  final List<_Message> messages;

  _Chat({
    required this.chat_id,
    required this.title,
    required this.messages,
  });

  factory _Chat.fromJson(Map<String, dynamic> json) {
    var messagesFromJson = json['messages'] as List;
    List<_Message> messagesList = messagesFromJson.map((i) => _Message.fromJson(i)).toList();
    return _Chat(
      chat_id: json['chat_id'],
      title: json['chat_title'],
      messages: messagesList,
    );
  }
}

class _MessageWidget extends StatelessWidget {
  final _Message message;
  final VoidCallback onDelete;

  const _MessageWidget({
    Key? key,
    required this.message,
    required this.onDelete,
  }) : super(key: key);

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
          if (message.isUser)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
