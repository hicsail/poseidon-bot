import 'package:flutter/material.dart';
import 'package:app/chatpage.dart';
import 'package:app/settingspage.dart';
import 'package:app/widgets/SlideFromLeftPageRoute.dart';
import 'package:app/widgets/SlideFromRightMenuRoute.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title, Key? key}) : super(key: key);

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
          icon: const Icon(Icons.settings),
          iconSize: 25,
          onPressed: () {
            Navigator.push(
              context,
              SlideFromRightMenuRoute(
                menuWidget: const SettingsPage(), // Ensure the correct page is used
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
