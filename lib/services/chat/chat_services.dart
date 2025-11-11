import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/message.dart';
import '../auth/auth_services.dart';

class ChatServices {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();

  //get user stream
  Stream<List<Map<String, dynamic>>> getChatRooms() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return data;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String receiverId, message) async {
    final String currentUserId = _authServices.currentUser!.uid;
    final String currentUserEmail = _authServices.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  //delete message
  Future<void> deleteMessage(
      String userId, String otherUserId, String messageId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  //update message
  Future<void> updateMessage(String userId, String otherUserId,
      String messageId, String newMessage) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'message': newMessage});
  }
}