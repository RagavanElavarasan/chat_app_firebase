import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String name;
  final List<String> participants;
  final bool isGroup;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, bool>
      readStatus; // Tracks if each participant has read the last message

  ChatModel({
    required this.id,
    required this.name,
    required this.participants,
    required this.isGroup,
    this.lastMessage,
    this.lastMessageTime,
    this.readStatus = const {},
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      isGroup: map['isGroup'] ?? false,
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      readStatus: Map<String, bool>.from(map['readStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'participants': participants,
      'isGroup': isGroup,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'readStatus': readStatus,
    };
  }

  bool isReadByCurrentUser(String userId) {
    return readStatus[userId] ?? true; // Default to true if no status is found
  }
}
