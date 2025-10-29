import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/items_provider.dart';
import 'ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No sqflite init on web — we use SharedPreferences for items on web.
  final prefs = await SharedPreferences.getInstance();

  // First-run flag
  final isFirstRun = prefs.getBool('firstRunDone') != true;
  if (isFirstRun) {
    await prefs.setBool('firstRunDone', true);
  }

  final darkMode = prefs.getBool('darkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemsProvider()..init()),
      ],
      child: MyApp(darkMode: darkMode),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool darkMode;
  const MyApp({super.key, required this.darkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode = widget.darkMode;

  Future<void> _toggleTheme() async {
    setState(() => _darkMode = !_darkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solo 4 Persistence (Web)',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueGrey),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: HomePage(onToggleTheme: _toggleTheme, darkMode: _darkMode),
    );
  }
}
