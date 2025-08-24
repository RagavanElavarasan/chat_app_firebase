import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new individual chat
  Future<String> createIndividualChat(
      String currentUserId, String otherUserId) async {
    // Check if chat already exists
    QuerySnapshot snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in snapshot.docs) {
      ChatModel chat = ChatModel.fromMap(doc.data() as Map<String, dynamic>);
      if (chat.participants.contains(otherUserId) && !chat.isGroup) {
        return doc.id; // Return existing chat ID
      }
    }

    // Create new chat
    DocumentReference chatRef = await _firestore.collection('chats').add({
      'name': '', // Individual chats don't have names
      'participants': [currentUserId, otherUserId],
      'isGroup': false,
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    });

    return chatRef.id;
  }

  // Create a new group chat
  Future<String> createGroupChat(String name, List<String> participants) async {
    DocumentReference chatRef = await _firestore.collection('chats').add({
      'name': name,
      'participants': participants,
      'isGroup': true,
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    });

    return chatRef.id;
  }

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    // Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    // Update chat last message and reset read status
    DocumentSnapshot chatDoc =
        await _firestore.collection('chats').doc(chatId).get();
    Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
    Map<String, bool> readStatus =
        Map<String, bool>.from(chatData['readStatus'] ?? {});

    for (String participant in chatData['participants']) {
      if (participant != senderId) {
        readStatus[participant] =
            false; // Mark as unread for other participants
      }
    }

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
      'readStatus': readStatus,
    });
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Get user chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Get chat by ID
  Future<ChatModel> getChat(String chatId) async {
    DocumentSnapshot doc =
        await _firestore.collection('chats').doc(chatId).get();
    return ChatModel.fromMap({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    DocumentSnapshot chatDoc =
        await _firestore.collection('chats').doc(chatId).get();
    Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
    Map<String, bool> readStatus =
        Map<String, bool>.from(chatData['readStatus'] ?? {});

    readStatus[userId] = true; // Mark as read for the current user

    await _firestore.collection('chats').doc(chatId).update({
      'readStatus': readStatus,
    });
  }
}
