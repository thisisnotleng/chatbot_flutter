import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/api_service.dart';
import 'chat_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/agri_tech_logo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto Bold',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0a3b03),
                  foregroundColor: Colors.white,
                ),
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    int? userId = await ApiService.login(
      usernameController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (userId != null) {
      // Save login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userID', userId);

      // Navigate to chat screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: null, userID: userId),
        ),
      );
    } else {
      setState(() {
        errorMessage = "Login failed. Check credentials.";
      });
    }
  }
}
