import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'chat/chat_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Chat App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              _authController.logout();
            },
          ),
        ],
      ),
      body: ChatListScreen(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // Show users list to start a chat
          Get.toNamed('/users');
        },
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }
}
