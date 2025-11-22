// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zottz_ot/firebase_data_model.dart';
// import '../models/user_information.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user information
  Future<void> addUserInformation(UserInformation information) async {
    try {
      await _firestore.collection('user_information').add(information.toMap());
    } catch (e) {
      throw Exception('Failed to add user information: $e');
    }
  }

  // Update user information
  Future<void> updateUserInformation(String docId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('user_information').doc(docId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user information: $e');
    }
  }

  // Get all information for a specific user
  Stream<List<UserInformation>> getUserInformationStream(String userName) {
    return _firestore
        .collection('user_information')
        .where('userName', isEqualTo: userName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserInformation.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String userName) async {
    try {
      final query = await _firestore
          .collection('user_information')
          .where('userName', isEqualTo: userName)
          .limit(1)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username: $e');
    }
  }

  // Get all unique usernames
  Future<List<String>> getAllUsernames() async {
    try {
      final query = await _firestore
          .collection('user_information')
          .get();
      
      final usernames = query.docs
          .map((doc) => doc.data()['userName'] as String)
          .toSet()
          .toList();
        print(usernames);
      return usernames;
    } catch (e) {
      throw Exception('Failed to get usernames: $e');
    }
  }

  // Get user age
  Future<int> getUserAge(String userName) async {
    try {
      final query = await _firestore
          .collection('user_information')
          .where('userName', isEqualTo: userName)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data()['userAge'] as int;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get user age: $e');
    }
  }
}