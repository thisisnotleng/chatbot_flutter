import 'package:flutter/material.dart';
import 'package:my_first_app/data/notifiers.dart';
import '../../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/api_service.dart';
import 'login_page.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final int? chatId;
  final int userID;

  const ChatScreen({super.key, this.chatId, required this.userID});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Map<String, dynamic>>> messages;
  final TextEditingController msgController = TextEditingController();
  int? currentChatId;
  List<Map<String, dynamic>> tempMessages = [];

  bool showTyping = true; // show floating typing bubble
  Map<int, String> typingTexts = {}; // map for animated typing text

  @override
  void initState() {
    super.initState();
    currentChatId = widget.chatId;
    if (currentChatId != null) {
      messages = ApiService.fetchMessages(currentChatId!);
    } else {
      messages = Future.value([]);
    }
  }

  void _loadMessages(int chatId) {
    setState(() {
      currentChatId = chatId;
      messages = ApiService.fetchMessages(chatId);
      tempMessages.clear();
      typingTexts.clear();
    });
  }

  Future<void> sendMessage() async {
    String text = msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      tempMessages.add({'sender': 'user', 'message': text});
      showTyping = true; // show floating bubble
    });

    msgController.clear();

    final response = await ApiService.sendMessage(
      currentChatId,
      widget.userID,
      text,
    );

    if (response.containsKey('new_chat')) {
      setState(() {
        currentChatId = response['chat_id'];
      });
    }

    final backendMessages = await ApiService.fetchMessages(currentChatId!);

    // Animate bot messages character by character
    List<Map<String, dynamic>> newMessages = [...backendMessages];
    Map<int, String> animatedMap = {};
    for (int i = 0; i < newMessages.length; i++) {
      if (newMessages[i]['sender'] == 'bot') {
        animatedMap[i] = '';
        _animateText(newMessages[i]['message'], i);
      }
    }

    setState(() {
      messages = Future.value(newMessages);
      tempMessages.clear();
      showTyping = false;
    });
  }

  void _animateText(String fullText, int index) {
    int currentIndex = 0;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (currentIndex > fullText.length) {
        timer.cancel();
        return;
      }
      setState(() {
        typingTexts[index] = fullText.substring(0, currentIndex);
      });
      currentIndex++;
    });
  }

  void createNewChat() {
    setState(() {
      currentChatId = null;
      messages = Future.value([]);
      tempMessages.clear();
      typingTexts.clear();
    });
    Navigator.pop(context);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // remove login state
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> msg, int index) {
    final isUser = msg['sender'] == 'user';
    String displayText =
        msg['sender'] == 'bot' && typingTexts.containsKey(index)
            ? typingTexts[index]!
            : msg['message'];

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) // Bot avatar
          CircleAvatar(
            radius: 16,
            // child: Icon(Icons.smart_toy, size: 18),
            child: Image.asset('assets/images/agri_tech_logo.png'),
            backgroundColor: Colors.white,
          ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: isUser ? 48 : 8,
              right: isUser ? 8 : 48,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[200] : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayText,
              style: const TextStyle(fontFamily: 'Kantumruy Pro'),
            ),
          ),
        ),
        if (isUser) // User avatar
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          // child: Icon(Icons.smart_toy, size: 18),
          child: Image.asset('assets/images/agri_tech_logo.png'),
          backgroundColor: Colors.white,
        ),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 48),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Dot(),
              SizedBox(width: 4),
              Dot(delay: 100),
              SizedBox(width: 4),
              Dot(delay: 200),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AgriBot"),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeNotifier.value =
                      themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(color: Color(0xFF0a3b03)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: logout,
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416),
                        child: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "AgriTech",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, child) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(
                      "New Chat",
                      style: TextStyle(
                        color:
                            mode == ThemeMode.dark
                                ? Colors.white
                                : Color(0xFF0a3b03),
                      ),
                    ),
                    onPressed: createNewChat,
                  );
                },
              ),
            ),
            const SizedBox(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ApiService.fetchChats(widget.userID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats = snapshot.data!;
                  if (chats.isEmpty) {
                    return const Center(child: Text("No previous chats."));
                  }

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(chat['title']),
                          onTap: () => _loadMessages(chat['chat_id']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                currentChatId == null && tempMessages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/chatbot_vector.png',
                            height: 130,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Hello! How can we help you today?",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : FutureBuilder<List<Map<String, dynamic>>>(
                      future: messages,
                      builder: (context, snapshot) {
                        List<Map<String, dynamic>> allMessages = [];
                        if (snapshot.hasData) {
                          allMessages = [...snapshot.data!, ...tempMessages];
                        } else {
                          allMessages = [...tempMessages];
                        }

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            ...allMessages
                                .asMap()
                                .entries
                                .map(
                                  (entry) =>
                                      _buildMessageRow(entry.value, entry.key),
                                )
                                .toList(),
                            if (showTyping) _buildTypingIndicator(),
                          ],
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 10.0,
              bottom: 30.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: const Color(0xFF0a3b03),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Single dot for typing indicator
class Dot extends StatefulWidget {
  final int delay;
  const Dot({this.delay = 0, super.key});

  @override
  State<Dot> createState() => _DotState();
}

class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
    if (widget.delay != 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const CircleAvatar(radius: 4, backgroundColor: Colors.black54),
    );
  }
}
