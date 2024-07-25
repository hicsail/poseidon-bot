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
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.chat),
        iconSize: 25,
        onPressed: () {
          Navigator.push(context, SlideFromLeftPageRoute(widget: const ChatPage()));
        },
        alignment: FractionalOffset.topLeft,
      ),
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}