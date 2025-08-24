import 'package:chat_app/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/auth_controller.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select participants:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: _userController.users.length,
                  itemBuilder: (context, index) {
                    final user = _userController.users[index];
                    if (user.id == _authController.currentUser.value?.id) {
                      return const SizedBox(); // Skip current user
                    }

                    return CheckboxListTile(
                      title: Text(user.name),
                      value: _selectedUsers.contains(user.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(user.id);
                          } else {
                            _selectedUsers.remove(user.id);
                          }
                        });
                      },
                    );
                  },
                );
              }),
            ),
            Obx(() => _chatController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Professional blue
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 3, // Subtle shadow for depth
                    ),
                    onPressed: _createGroup,
                    child: const Text('Create Group'),
                  )),
          ],
        ),
      ),
    );
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a group name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one participant',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Add current user to participants
    List<String> participants = List.from(_selectedUsers);
    participants.add(_authController.currentUser.value!.id);

    String chatId = await _chatController.createGroupChat(
      _groupNameController.text.trim(),
      participants,
    );

    Get.back(); // Close create group screen
    Get.to(
      () => ChatScreen(
          chatId: chatId, chatName: _groupNameController.text.trim()),
    );
  }
}
