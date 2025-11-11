import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_services.dart';
import '../widgets/my_drawer.dart';
import '../widgets/user_tile.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatServices _chatServices = ChatServices();
  final AuthServices _authServices = AuthServices();

  User? getCurrentUser() {
    return _authServices.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: const Text("Error"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading...."));
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userdata) => _buildUserListItem(userdata, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userdata,
    BuildContext context,
  ) {
    if (userdata["email"] != getCurrentUser()!.email) {
      return UserTile(
        text: userdata['email'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                userEmail: userdata["email"],
                receiverId: userdata["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
