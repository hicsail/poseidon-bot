import 'package:app/chatpage.dart';
import 'package:app/widgets/SlideFromLeftPageRoute.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.chat),
        iconSize: 25,
        onPressed: () {
          Navigator.push(context, SlideFromLeftPageRoute(widget: const ChatPage()));
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings),
          iconSize: 25,
          onSelected: (String result) {
            if (result == 'Profile') {}
            else if (result == 'Logout') {}
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'Logout',
              child: Text('Logout'),
            )
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
