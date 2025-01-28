import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      // Enable network for web platform
      if (kIsWeb) {
        await _firestore.enableNetwork();
      }

      final QuerySnapshot querySnapshot = await _firestore
          .collection('User')
          .where('user_id', isEqualTo: email.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server)); // Force server request

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No user found with email: $email');
        return null;
      }

      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      
      if (userData['user_password'] != password) {
        debugPrint('Invalid password for user: $email');
        return null;
      }

      debugPrint('Login successful for user: $email');
      return UserModel.fromMap(userData);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        // Clear any cached data
        await _firestore.clearPersistence();
        await _firestore.terminate();
        await _firestore.enableNetwork();
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }
}
