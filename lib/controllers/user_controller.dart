import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();

  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // Load all users
  void loadUsers() {
    _databaseService.getUsers().listen((usersList) {
      users.value = usersList;
    });
  }

  // Get user by ID
  UserModel getUserById(String userId) {
    return users.firstWhere((user) => user.id == userId,
        orElse: () => UserModel(id: '', name: 'Unknown', email: ''));
  }
}
