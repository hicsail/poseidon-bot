import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/widgets/PoseidonAppBar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? _selectedFile;
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
        // For web, we cannot access the file path, so we'll use the bytes and name
        setState(() {
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
