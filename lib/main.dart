import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/pages/login_page.dart';
import 'views/pages/chat_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check login state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  int? userID = prefs.getInt('userID');

  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MyApp(
          isLoggedIn: isLoggedIn,
          userID: userID,
          themeMode: currentMode,
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int? userID;
  final ThemeMode themeMode;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.userID,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Tech Chatbot',
      theme: ThemeData(primarySwatch: Colors.green),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home:
          isLoggedIn && userID != null
              ? ChatScreen(userID: userID!, chatId: null)
              : const LoginPage(),
    );
  }
}
