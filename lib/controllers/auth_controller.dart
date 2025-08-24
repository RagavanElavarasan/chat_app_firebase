import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          // Get user data from Firestore
          UserModel userData = await _databaseService.getUser(user.uid);
          currentUser.value = userData;
          errorMessage.value = '';
        } catch (e) {
          print('Error fetching user data: $e');
          // Create a user document if it doesn't exist
          UserModel newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
          );
          await _databaseService.updateUserData(newUser);
          currentUser.value = newUser;
          errorMessage.value = '';
        }
      } else {
        currentUser.value = null;
        errorMessage.value = '';
      }
    });
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      User? user =
          await _authService.signInWithEmailAndPassword(email, password);
      isLoading.value = false;

      if (user != null) {
        errorMessage.value = '';
        return true;
      } else {
        errorMessage.value = 'Login failed. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      User? user = await _authService.registerWithEmailAndPassword(
          email, password, name);

      if (user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
        );
        await _databaseService.updateUserData(newUser);
        currentUser.value = newUser;
        isLoading.value = false;
        errorMessage.value = '';
        return true;
      } else {
        isLoading.value = false;
        errorMessage.value = 'Registration failed. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      currentUser.value = null;
      errorMessage.value = '';
      Get.offAllNamed(AppRoutes.login); // Navigate to login screen after logout
    } catch (e) {
      errorMessage.value = 'Logout failed. Please try again.';
      print('Logout error: $e');
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address format.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  // Get current user ID
  String? get currentUserId => currentUser.value?.id;

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
