import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_session.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'chat_sessions';

  // Create a new chat session
  Future<String> createChatSession({
    required String title,
    String? mood,
    String? addictionType,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw 'User must be signed in to save chat history';
    }

    final docRef = _firestore.collection(_collection).doc();
    final session = ChatSession(
      id: docRef.id,
      userId: user.uid,
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      mood: mood,
      addictionType: addictionType,
    );

    await docRef.set(session.toJson());
    return docRef.id;
  }

  // Add a message to an existing session
  Future<void> addMessage({
    required String sessionId,
    required String role,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    final message = ChatMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );

    await _firestore.collection(_collection).doc(sessionId).update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all chat sessions for the current user
  Stream<List<ChatSession>> getUserChatSessions() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatSession.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Get a specific chat session
  Future<ChatSession?> getChatSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    final doc = await _firestore.collection(_collection).doc(sessionId).get();
    if (!doc.exists) return null;

    return ChatSession.fromJson(doc.data()!, doc.id);
  }

  // Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    await _firestore.collection(_collection).doc(sessionId).delete();
  }

  // Update chat session title
  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    await _firestore.collection(_collection).doc(sessionId).update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get recent chat sessions (limited to 5)
  Future<List<ChatSession>> getRecentSessions({int limit = 5}) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return [];

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatSession.fromJson(doc.data(), doc.id))
        .toList();
  }
}
