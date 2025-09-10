import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl =
    "http://10.0.2.2:5000"; // Android emulator points to host PC

class ApiService {
  // Store session cookie manually
  static String? sessionCookie;

  static Map<String, String> get headers {
    final map = {"Content-Type": "application/json"};
    if (sessionCookie != null) {
      map["Cookie"] = sessionCookie!;
    }
    return map;
  }

  // --- LOGIN ---
static Future<int?> login(String username, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/api/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"username": username, "password": password}),
  );

  if (response.statusCode == 200) {
    // Capture session cookie
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      sessionCookie = rawCookie.split(';')[0];
    }

    // Parse user_id from JSON
    final Map<String, dynamic> json = jsonDecode(response.body);
    return json['user_id']; // returns int
  } else {
    return null; // login failed
  }
}


  // --- FETCH CHATS ---
  static Future<List<Map<String, dynamic>>> fetchChats(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/chats/$userId"), // pass user_id
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch chats");
    }
  }


  // --- FETCH MESSAGES ---
  static Future<List<Map<String, dynamic>>> fetchMessages(int chatId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/load-chat/$chatId"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["messages"]);
    } else {
      throw Exception("Failed to fetch messages");
    }
  }

  // --- SEND MESSAGE ---
  static Future<Map<String, dynamic>> sendMessage(
    int? chatId,
    int userId, // <- add userId parameter
    String message,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/send-message"),
      headers: headers,
      body: jsonEncode({
        "chat_id": chatId,
        "user_id": userId, // <- include user_id
        "message": message
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send message");
    }
  }

}
