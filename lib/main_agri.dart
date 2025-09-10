import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hello, Welcome to Agritech"},
  ];
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
    });
    _controller.clear();

    try {
      // Change URL to your Flask backend
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/get-response"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "bot", "text": data["response"]});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Error: ${response.statusCode}",
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg["text"] ?? ""),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 8,
              right: 8,
              bottom: 20,
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
