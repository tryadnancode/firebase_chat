
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade100,
    primary: Colors.blue,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade300,
    onSecondary: Colors.black,
    inversePrimary: Colors.grey.shade800,
  ),
);
