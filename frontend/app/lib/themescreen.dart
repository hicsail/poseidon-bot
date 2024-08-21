import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ThemeNotifier class to manage theme changes
class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}

class ColorPair {
  final Color primary;
  final Color secondary;

  ColorPair({required this.primary, required this.secondary});
}

final List<ColorPair> colorPairs = [
  ColorPair(primary: Color.fromARGB(255, 173, 232, 245), secondary: Color.fromARGB(255, 245, 186, 173)),
  ColorPair(primary: Colors.green, secondary: Colors.yellow),
  ColorPair(primary: Colors.purple, secondary: Colors.red),
];

// Function to create a ThemeData object from a ColorPair
ThemeData createTheme(ColorPair colorPair) {
  return ThemeData(
    primaryColor: colorPair.primary,
    hintColor: colorPair.secondary,
    appBarTheme: AppBarTheme(
      color: colorPair.primary,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: colorPair.secondary,
    ),
  );
}

class ThemeScreen extends StatefulWidget {
  @override
  ThemeScreenState createState() => ThemeScreenState();
}

class ThemeScreenState extends State<ThemeScreen> {
  ColorPair selectedColorPair = colorPairs[0];

    @override
  void initState() {
    super.initState();
    // Initialize with the current theme's color pair
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    selectedColorPair = colorPairs.firstWhere(
      (pair) => pair.primary == themeNotifier.themeData.primaryColor,
      orElse: () => colorPairs[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Choose Theme')),
      body: ListView.builder(
        itemCount: colorPairs.length,
        itemBuilder: (context, index) {
          final colorPair = colorPairs[index];
          return ListTile(
            title: Text('Theme ${index + 1}'),
            tileColor: colorPair.primary.withOpacity(0.2),
            trailing: selectedColorPair == colorPair
                ? Icon(Icons.check, color: colorPair.secondary)
                : null,
            onTap: () {
              setState(() {
                selectedColorPair = colorPair;
              });
              // Apply the selected theme using ThemeNotifier
              themeNotifier.setTheme(createTheme(colorPair));
            },
          );
        },
      ),
    );
  }
}