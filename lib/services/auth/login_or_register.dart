import 'package:flutter/material.dart';
import '../../screens/login_page.dart';
import '../../screens/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});
  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true;

  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(onPressed:toggleScreens);
    }else{
      return RegisterPage(onPressed: toggleScreens,);
    }
  }
}
