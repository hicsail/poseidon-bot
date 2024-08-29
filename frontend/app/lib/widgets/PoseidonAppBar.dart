import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/chatpage.dart';
import 'package:app/settingspage.dart';
import 'package:app/widgets/SlideFromLeftPageRoute.dart';

class SlidingMenuApp extends StatefulWidget {
  @override
  SlidingMenuAppState createState() => SlidingMenuAppState();
}

class SlidingMenuAppState extends State<SlidingMenuApp> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        onMenuPressed: toggleMenu,
      ),
      body: Stack(
        children: <Widget>[
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
          // Main content goes here
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const CustomAppBar({required this.title, required this.onMenuPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.chat),
        iconSize: 25,
        onPressed: () {
          Navigator.push(
            context,
            SlideFromLeftPageRoute(widget: const ChatPage()),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          iconSize: 25,
          onPressed: onMenuPressed,
        ),
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}