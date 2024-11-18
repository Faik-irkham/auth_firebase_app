// ignore_for_file: use_build_context_synchronously

import 'package:auth_firebase_app/pages/main_page.dart';
import 'package:auth_firebase_app/pages/sign_in_page.dart';
import 'package:auth_firebase_app/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MonaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0XFFFFC600),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/auth_checker',
      routes: {
        '/auth_checker': (context) => const AuthChecker(),
        '/sign_in': (context) => const SignInPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/home': (context) => const MainPage(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan indikator loading sementara
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Jika pengguna sudah login, arahkan ke HomePage
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } else {
          // Jika belum login, arahkan ke SignInPage
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/sign_in');
          });
        }

        return const SizedBox(); // Return widget kosong karena navigasi langsung diproses
      },
    );
  }
}
