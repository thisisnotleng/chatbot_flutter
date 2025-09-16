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
  final TextEditingController msgController = TextEditingController();

  int? currentChatId;
  bool showTyping = false;
  Map<int, String> typingTexts = {}; // bot animated texts
  Map<int, List<Map<String, dynamic>>> chatCache = {}; // cache chat history
  List<Map<String, dynamic>> chatListCache = [];
  bool chatListLoaded = false;
  int typingAnimationSpeedMs = 40; // Lower is faster

  @override
  void initState() {
    super.initState();
    currentChatId = widget.chatId;
    if (currentChatId != null) {
      _loadMessages(currentChatId!);
    }
    _loadChatList();
  }

  Future<void> _loadChatList() async {
    if (!chatListLoaded) {
      final chats = await ApiService.fetchChats(widget.userID);
      setState(() {
        chatListCache = chats;
        chatListLoaded = true;
      });
    }
  }

  void _loadMessages(int chatId) async {
    // Only fetch if not in cache
    if (chatCache.containsKey(chatId)) {
      setState(() {
        currentChatId = chatId;
        typingTexts.clear();
      });
    } else {
      final fetched = await ApiService.fetchMessages(chatId);
      setState(() {
        currentChatId = chatId;
        chatCache[chatId] = fetched;
        typingTexts.clear();
      });
    }
  }

  Future<void> sendMessage() async {
    String text = msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      showTyping = true;
      chatCache[currentChatId ?? -1] = [
        ...(chatCache[currentChatId ?? -1] ?? []),
        {'sender': 'user', 'message': text},
      ];
    });

    msgController.clear();

    final response = await ApiService.sendMessage(
      currentChatId,
      widget.userID,
      text,
    );

    // If a new chat was created, update chat id and cache
    if (response.containsKey('new_chat')) {
      final newChat = response['new_chat'];
      setState(() {
        currentChatId = newChat['chat_id'];
        chatCache[currentChatId!] = [
          {'sender': 'user', 'message': text},
        ];
        // Add new chat to chat list cache if not present
        if (!chatListCache.any((c) => c['chat_id'] == newChat['chat_id'])) {
          chatListCache.insert(0, newChat);
        }
      });
    }

    // Update chatCache directly with bot reply from response
    if (response.containsKey('response')) {
      setState(() {
        chatCache[currentChatId!] = [
          ...(chatCache[currentChatId!] ?? []),
          {'sender': 'bot', 'message': response['response']},
        ];
      });
      // Animate bot message
      int botIndex = (chatCache[currentChatId!]?.length ?? 1) - 1;
      _animateText(response['response'], botIndex);
    }

    setState(() {
      showTyping = false;
    });
  }

  void _animateText(String fullText, int index) {
    int currentIndex = 0;
    Timer.periodic(Duration(milliseconds: typingAnimationSpeedMs), (timer) {
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
      typingTexts.clear();
      chatCache.remove(-1); // clear temp new chat cache
    });
    Navigator.pop(context);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        final userBg = isDark ? Colors.blue[700] : Colors.blue[200];
        final botBg = isDark ? Colors.grey[800] : Colors.grey[300];
        final userText = isDark ? Colors.white : Colors.black;
        final botText = isDark ? Colors.white : Colors.black;
        return Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              CircleAvatar(
                radius: 16,
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
                  color: isUser ? userBg : botBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    color: isUser ? userText : botText,
                  ),
                ),
              ),
            ),
            if (isUser)
              const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
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
    final currentMessages =
        currentChatId == null
            ? (chatCache[-1] ?? [])
            : (chatCache[currentChatId!] ?? []);

    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          "AgriBot",
          style: TextStyle(
            fontFamily: 'Kantumruy Pro Bold',
            color: (Colors.black54),
          ),
        ),
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
              child:
                  chatListLoaded
                      ? (chatListCache.isEmpty
                          ? const Center(child: Text("No previous chats."))
                          : ListView.builder(
                            itemCount: chatListCache.length,
                            itemBuilder: (context, index) {
                              final chat = chatListCache[index];
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
                          ))
                      : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                currentChatId == null && currentMessages.isEmpty
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
                    : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        ...currentMessages
                            .asMap()
                            .entries
                            .map(
                              (entry) =>
                                  _buildMessageRow(entry.value, entry.key),
                            )
                            .toList(),
                        if (showTyping) _buildTypingIndicator(),
                      ],
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
                    style: const TextStyle(fontFamily: 'Kantumruy Pro'),
                    controller: msgController,
                    maxLines: null, // allow multi-line
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0a3b03)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0a3b03)),
                      ),
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

// Typing dots
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
