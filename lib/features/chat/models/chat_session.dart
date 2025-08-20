import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String userId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mood;
  final String? addictionType;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.addictionType,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json, String id) {
    return ChatSession(
      id: id,
      userId: json['userId'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      mood: json['mood'] as String?,
      addictionType: json['addictionType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'mood': mood,
      'addictionType': addictionType,
    };
  }
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
