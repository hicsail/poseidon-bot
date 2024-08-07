import 'package:app/chatpage.dart';
import 'package:app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> members = [];

  MyAppState() {
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/members'));
    if (response.statusCode == 200) {
      members = json.decode(response.body)['members'];
      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something Random:'),
            Text(appState.current.asLowerCase),
            const SizedBox(height: 20),
            appState.members.isEmpty
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: appState.members.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(appState.members[index].toString()),
                        );
                      },
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                appState.fetchData(); // Fetch data again on button press
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
