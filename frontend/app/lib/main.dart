import 'package:app/chatpage.dart';
import 'package:app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poseidon Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/chat': (context) => const ChatPage(),
      },
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({sper.key, required this.title});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appbar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center
        children: [
          const Text('Something Random:'),
          Text(appState.current.asLowerCase),

          ElevatedButton: () {
            print('button pressed!');
          },
          child: Text('Next'),
        ],
      ),
    );
  }
}