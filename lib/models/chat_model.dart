import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String name;
  final List<String> participants;
  final bool isGroup;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatModel({
    required this.id,
    required this.name,
    required this.participants,
    required this.isGroup,
    this.lastMessage,
    this.lastMessageTime,
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
    };
  }
}
