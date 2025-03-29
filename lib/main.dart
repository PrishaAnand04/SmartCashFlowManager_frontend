import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Cash Flow Manager',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AuthPage(),
    );
  }
}