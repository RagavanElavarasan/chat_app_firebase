import 'package:get/get.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  RxList<ChatModel> chats = <ChatModel>[].obs;
  RxList<MessageModel> currentChatMessages = <MessageModel>[].obs;
  RxString currentChatId = ''.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // Load user chats
  void loadUserChats(String userId) {
    _chatService.getUserChats(userId).listen((chatsList) {
      chats.value = chatsList;
    });
  }

  // Load messages for a chat
  void loadChatMessages(String chatId) {
    currentChatId.value = chatId;
    _chatService.getMessages(chatId).listen((messages) {
      currentChatMessages.value = messages;
    });
  }

  // Send a message
  Future<void> sendMessage(String text, String senderId) async {
    if (text.trim().isEmpty) return;

    await _chatService.sendMessage(
      currentChatId.value,
      senderId,
      text.trim(),
    );
  }

  // Create individual chat
  Future<String> createIndividualChat(
      String currentUserId, String otherUserId) async {
    isLoading.value = true;
    String chatId =
        await _chatService.createIndividualChat(currentUserId, otherUserId);
    isLoading.value = false;
    return chatId;
  }

  // Create group chat
  Future<String> createGroupChat(String name, List<String> participants) async {
    isLoading.value = true;
    String chatId = await _chatService.createGroupChat(name, participants);
    isLoading.value = false;
    return chatId;
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    await _chatService.markChatAsRead(chatId, userId);
  }
}
