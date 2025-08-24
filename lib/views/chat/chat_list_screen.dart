import 'package:chat_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/chat_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final AuthController _authController = Get.find<AuthController>();

  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Get.toNamed('/create-group');
            },
          ),
        ],
      ),
      body: Obx(() {
        // Check if current user is null
        if (_authController.currentUser.value == null) {
          return const Center(
            child: Text('Please login first'),
          );
        }

        final String currentUserId = _authController.currentUser.value!.id;

        // Load user chats when user is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _chatController.loadUserChats(currentUserId);
        });

        if (_chatController.chats.isEmpty) {
          return const Center(
            child: Text('No chats yet. Start a conversation!'),
          );
        }

        return ListView.builder(
          itemCount: _chatController.chats.length,
          itemBuilder: (context, index) {
            ChatModel chat = _chatController.chats[index];
            String chatName = chat.isGroup
                ? chat.name
                : _getOtherUserName(chat, currentUserId);

            return ListTile(
              leading: chat.isGroup
                  ? Icon(
                      Icons.group,
                      size: 30,
                    )
                  : Icon(Icons.person, size: 30),
              title: Text(chatName),
              subtitle: Text(
                chat.lastMessage ?? 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: chat.lastMessageTime != null
                  ? Text(
                      DateFormat('HH:mm').format(chat.lastMessageTime!),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
              onTap: () {
                Get.to(
                  () => ChatScreen(chatId: chat.id, chatName: chatName),
                );
              },
            );
          },
        );
      }),
    );
  }

  String _getOtherUserName(ChatModel chat, String currentUserId) {
    if (chat.isGroup) return chat.name;

    for (String participantId in chat.participants) {
      if (participantId != currentUserId) {
        final user = _userController.getUserById(participantId);
        return user.name;
      }
    }
    return 'Unknown User';
  }
}
