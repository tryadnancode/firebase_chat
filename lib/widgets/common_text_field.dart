import 'package:flutter/material.dart';

class CommonTextField extends StatefulWidget {
  final bool isPassword;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;

  const CommonTextField({
    super.key,
    this.isPassword = false,
    this.controller,
    this.hintText,
    this.keyboardType,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscureText : false,
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: _toggleVisibility,
        )
            : null,
      ),
    );
  }
}
