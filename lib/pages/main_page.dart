import 'package:auth_firebase_app/pages/home_page.dart';
import 'package:auth_firebase_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Daftar halaman untuk navigasi
  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _currentIndex,
        selectedIconTheme: const IconThemeData(
          color: Color(0XFFFFC600),
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/chart.png',
              color: _currentIndex == 0 ? const Color(0XFFFFC600) : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/profile.png',
              color: _currentIndex == 1 ? const Color(0XFFFFC600) : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
