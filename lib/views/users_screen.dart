import 'package:chat_app/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/auth_controller.dart';

class UsersScreen extends StatelessWidget {
  final UserController _userController = Get.find<UserController>();
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();

  UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User to Chat With'),
      ),
      body: Obx(() {
        // Check if current user is null
        if (_authController.currentUser.value == null) {
          return const Center(
            child: Text('Please login first'),
          );
        }

        final String currentUserId = _authController.currentUser.value!.id;

        if (_userController.users.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Filter out current user
        final otherUsers = _userController.users
            .where((user) => user.id != currentUserId)
            .toList();

        if (otherUsers.isEmpty) {
          return const Center(
            child: Text('No other users found'),
          );
        }

        return ListView.builder(
          itemCount: otherUsers.length,
          itemBuilder: (context, index) {
            final user = otherUsers[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              onTap: () async {
                // Show loading indicator
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  barrierDismissible: false,
                );

                try {
                  // Create individual chat
                  String chatId = await _chatController.createIndividualChat(
                    currentUserId,
                    user.id,
                  );

                  // Close loading dialog and users screen
                  Get.back(); // Close loading dialog
                  Get.back(); // Close users screen

                  // Navigate to chat screen
                  Get.to(
                    () => ChatScreen(chatId: chatId, chatName: user.name),
                  );
                } catch (e) {
                  // Close loading dialog and show error
                  Get.back(); // Close loading dialog
                  Get.snackbar(
                    'Error',
                    'Failed to create chat: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            );
          },
        );
      }),
    );
  }
}
