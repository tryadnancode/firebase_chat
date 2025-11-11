import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/widgets/common_button.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_services.dart';
import '../widgets/common_text_field.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final void Function()? onPressed;

  LoginPage({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    Future<void> login(BuildContext context) async {
      final auth = AuthServices();

      try {
        await auth.userSignInWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome back 👋'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format.';
        } else {
          message = 'Login failed. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text("Welcome back, you've been missed!"),
              const SizedBox(height: 16),
              CommonTextField(
                controller: emailController,
                hintText: "Email",
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: passwordController,
                isPassword: true,
                hintText: "Password",
              ),
              const SizedBox(height: 16),
              CommonButton(
                text: "Login",
                onTap: () => login(context),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                    Text(
                      "Register Now",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
