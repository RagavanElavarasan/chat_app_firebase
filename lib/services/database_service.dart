import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user document
  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Get user data by ID
  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Return a default user or throw an exception
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Get all users
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Handle null data
        if (doc.data() == null) {
          return UserModel(id: doc.id, name: 'Unknown', email: '');
        }
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
