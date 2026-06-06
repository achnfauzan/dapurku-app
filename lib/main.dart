import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'page/login.dart';
import 'page/register.dart';
import 'main_page.dart';
import 'page/splash_screen.dart';
import 'page/welcome_page.dart';
import 'page/edit_profil.dart';
import 'data/seed_firestore.dart';
import 'page/tambah_resep.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await seedRecipes();
await seedChefs();
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
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainPage(),
        '/edit_profil': (context) => const EditProfilPage(),
        '/tambah_resep':(context) => const TambahResepPage(),
      },
    );
  }
}