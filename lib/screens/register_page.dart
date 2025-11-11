import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/widgets/common_button.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_services.dart';
import '../widgets/common_text_field.dart';

class RegisterPage extends StatelessWidget {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final void Function()? onPressed;

  RegisterPage({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {

    Future<void> register(BuildContext context) async {
      if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Passwords do not match. Please re-enter."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      try {
        final _auth = AuthServices();

        await _auth.userSignUpWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! 🎉"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

      } on FirebaseAuthException catch (e) {
        String message = '';

        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format.';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak. Please choose a stronger one.';
        } else {
          message = 'Registration failed. Please try again.';
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
            content: Text("Something went wrong: $e"),
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
              Icon(Icons.message, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text("Let's create an account for you"),
              const SizedBox(height: 16),
              CommonTextField(
              controller: emailController,
              hintText: "Email",),
              const SizedBox(height: 16),
              CommonTextField(controller: passwordController,
                isPassword: true,hintText: "Password",),
              const SizedBox(height: 16),
              CommonTextField(controller: confirmPasswordController,
                isPassword: true,hintText: "Confirm Password",),
              const SizedBox(height: 16),
              CommonButton(text: "Signup", onTap: () => register(context)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                    Text("Login Now",style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),)
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
