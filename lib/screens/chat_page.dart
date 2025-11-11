import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth/auth_services.dart';
import '../services/chat/chat_services.dart';
import '../widgets/common_text_field.dart';

class ChatPage extends StatefulWidget {
  final String userEmail;
  final String receiverId;

  const ChatPage({super.key, required this.userEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();

  final ChatServices _chatServices = ChatServices();

  final AuthServices _authServices = AuthServices();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 500), () {
      scrollDown();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final keyboardVisible = View.of(context).viewInsets.bottom > 0;
    if (keyboardVisible) {
      scrollDown();
    }
  }

  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      await _chatServices.sendMessage(
        widget.receiverId,
        messageController.text.trim(),
      );
      messageController.clear();
      scrollDown();
    }
  }

  void _showEditDeleteMenu(
      BuildContext context, String messageId, String currentMessage) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(context, messageId, currentMessage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  deleteMessage(messageId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(
      BuildContext context, String messageId, String currentMessage) {
    TextEditingController editController =
        TextEditingController(text: currentMessage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: CommonTextField(
          controller: editController,
          hintText: "Edit your message",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                _chatServices.updateMessage(_authServices.currentUser!.uid,
                    widget.receiverId, messageId, editController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _chatServices.deleteMessage(
                  _authServices.currentUser!.uid, widget.receiverId, messageId);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.userEmail),
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
      stream: _chatServices.getMessages(senderId, widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading...."));
        }
        return ListView(
          controller: _scrollController,
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
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: () {
        if (isCurrentUser) {
          _showEditDeleteMenu(context, doc.id, data['message']);
        }
      },
      child: Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment:
                isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a')
                    .format((data['timestamp'] as Timestamp).toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0, top: 8, left: 8, right: 8),
      child: Row(
        children: [
          Expanded(
            child: CommonTextField(
              focusNode: _focusNode,
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
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ))),
        ],
      ),
    );
  }
}
