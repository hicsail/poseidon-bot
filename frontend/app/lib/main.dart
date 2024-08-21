import 'package:flutter/material.dart';
import 'package:app/chatpage.dart';
import 'package:app/widgets/PoseidonAppBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poseidon Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 245, 186, 173),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SlidingMenuApp(), // Use SlidingMenuApp as the home
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}
