import 'package:flutter/material.dart';
import 'page/login.dart';
import 'page/register.dart';
import 'main_page.dart';
import 'page/splash_screen.dart';
import 'page/welcome_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resep App',
      home: const SplashPage(),

      routes: {
        '/welcome' : (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
