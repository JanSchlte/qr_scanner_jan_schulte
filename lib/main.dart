import 'package:flutter/material.dart';
import 'package:qr_scanner/screens/home_screen.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';

//Alle Änderungen in Dateien, welche sich nicht im \lib Ordner befinden habe ich mit ToDo Kommentaren gekennzeichnet, damit Sie diese leichter finden

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Die App Routen werden festgelegt, damit später besser zwischen den Screens gewechselt werden kann
      initialRoute: 'home_screen',
      routes: {
        'home_screen': (context) => HomeScreen(),
        'scanner_screen': (context) => ScannerScreen(),
      },
      //Debug Banner wird entfernt
      debugShowCheckedModeBanner: false,
    );
  }
}
