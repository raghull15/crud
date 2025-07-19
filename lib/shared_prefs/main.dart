import 'package:flutter/material.dart';
import 'package:crud/shared_prefs/pref_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SharedPrefs example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 33, 236, 175)),
        fontFamily: 'Pacifico',
      ),
      home: const PrefDemoPage(),
    );
  }
}
