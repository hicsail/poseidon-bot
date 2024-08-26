import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/widgets/PoseidonAppBar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? _selectedFile;
  String? _fileText;
  String? _fileName;
  int? _fileSize;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.single;

      if (kIsWeb) {
        // print(platformFile.path);
        // platformFile.readStream!.listen((value) {
        //   print(value);
        // });
        // For web, we cannot access the file path, so we'll use the bytes and name
        setState(() {
          List<int> bytes = platformFile.bytes!;
          _fileText = utf8.decode(bytes);
          _fileName = platformFile.name;
          _fileSize = platformFile.size;
        });
      } else {
        File file = File(platformFile.path!);        
        setState(() {
          _selectedFile = file;
          _fileName = platformFile.name;
          _fileSize = file.lengthSync(); 
        });
      }

      print('File selected: $_fileName, Size: $_fileSize bytes');
    } else {
      print('No file selected.');
    }
  }

  Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

  Future<void> _sendDocument() async {
    try {
      List<String> lines = _fileText!.split('\n').where((l) => l != '').toList();
      print('Sending file to Poseidon Bot...');
      final response = await http.post(
      Uri.parse('http://localhost:5001/document/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'document': lines,
      }),
    );
    if (response.statusCode == 200) {
      print('Document sent to Poseidon Bot.');
    } else {
      throw Exception(response.body);
    }
    } catch(e) {
      print('Error sending document to Poseidon Bot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            // Display selected file
            _fileName != null
                ? Card(
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(_fileName ?? 'Unknown file'),
                      subtitle: Text(
                        'Size: ${(_fileSize! / 1024).toStringAsFixed(2)} KB',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _fileName = null;
                            _fileSize = null;
                          });
                        },
                      ),
                    ),
                  )
                : const Text('No document selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDocument,
              child: const Text('Pick a Document'),
            ),
            ElevatedButton(
              onPressed: _sendDocument,
              child: const Text('Upload to Poseidon Bot'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
