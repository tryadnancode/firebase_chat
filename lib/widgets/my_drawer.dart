import 'package:flutter/material.dart';
import '../screens/setting_page.dart';
import '../services/auth/auth_services.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final _auth = AuthServices();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthServices().currentUser;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.email ?? 'Not logged in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary,),
                  title: Text("H O M E", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,),
                  title: Text("S E T T I N G S", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary,),
              title: Text("L O G O U T", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              onTap: () {
                logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
