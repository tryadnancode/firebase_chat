import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth/auth_services.dart';
import '../services/chat/chat_services.dart';
import '../widgets/common_text_field.dart';

class ChatPage extends StatelessWidget {
  final String userEmail;
  final String receiverId;

  ChatPage({super.key, required this.userEmail, required this.receiverId});

  final TextEditingController messageController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final AuthServices _authServices = AuthServices();

  void sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      await _chatServices.sendMessage(
        receiverId,
        messageController.text.trim(),
      );
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(userEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildUserInput(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authServices.currentUser!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(senderId, receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading...."));
        }
        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _authServices.currentUser!.uid;

    var bubbleColor = isCurrentUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;
    var alignment =
        isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(
                left: isCurrentUser ? 50 : 0, right: isCurrentUser ? 0 : 50),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data['message'],
              style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: CommonTextField(
              hintText: "Enter Message...",
              controller: messageController,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle),
              child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.arrow_upward))),
        ],
      ),
    );
  }
}
