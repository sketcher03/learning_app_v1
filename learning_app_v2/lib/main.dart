import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:learning_app/auth/signup_page.dart';
import 'package:provider/provider.dart';
import 'auth/login_page.dart';
import 'auth/login_page.dart';
//import 'home_page.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning App',
      theme: ThemeData(
        primaryColor: Colors.white,
        //colorScheme: const ColorScheme.light(
          //primary: Color.white,
          //secondary: Color.white,
          //surface: Colors.white,
        //),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),

      home: SignUpPage(),
      //login: const LoginPage(),
    );
  }
}