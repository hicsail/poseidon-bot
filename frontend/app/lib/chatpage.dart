import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:app/settingspage.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

const MainColor = Color.fromARGB(255, 173, 232, 245);

class ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
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
  void handleSubmitted(String text) {
    if (text.isEmpty) return;
    Duration speed;
    String botResponse = "This is a simulated bot response.";
    if (botResponse.length < 100) {
      speed = Duration(milliseconds: 30);
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
    });
    textController.clear();
    Future.delayed(Duration(milliseconds: 100), () {
      scrollToBottom();
    });
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
    final messageBarHeight = 5.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor,
        title: Center(
          child: Text(
            'Poseidon-Bot',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleMenu,
          ),
        ],
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageWidget(
                        message: messages[index],
                        onAnimationFinished: () {
                          if (!messages[index].isUser) {
                            // Handle animation finished for bot messages if needed
                          }
                        },
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
                              color: canSend ? MainColor : Colors.grey,
                            ),
                            iconSize: 40.0,
                            onPressed: canSend ? () {
                              handleSubmitted(textController.text);
                            } : null,
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
                width: MediaQuery.of(context).size.width * 1 / 3, // Right 1/3 of the screen
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
                          CupertinoPageRoute(builder: (context) => SettingsPage()),
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
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isAnimated;
  final Duration? animationSpeed;
  bool hasBeenAnimated;
  ChatMessage({
    required this.text,
    required this.isUser,
    this.isAnimated = false,
    this.animationSpeed,
    this.hasBeenAnimated = false,
  });
}
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAnimationFinished;
  const ChatMessageWidget({
    required this.message,
    this.onAnimationFinished,
  });
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
                style: TextStyle(fontSize: 20.0),
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
              color: message.isUser ? Colors.grey[300] : MainColor,
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
                ),
          ),
        ],
      ),
    );
  }
}