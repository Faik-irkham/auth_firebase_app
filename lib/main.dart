import 'package:auth_firebase_app/pages/home_page.dart';
import 'package:auth_firebase_app/pages/sign_in_page.dart';
import 'package:auth_firebase_app/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0XFFFFC600),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => const SignInPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
