import 'package:flutter/material.dart';
import '../page/homepage.dart';
import '../page/discover.dart';
import '../page/favorite.dart';
import '../page/profil.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final pages = const [
    HomePage(),
    DiscoverPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed, 
  currentIndex: _index,
  onTap: (value) {
    setState(() {
      _index = value;
    });
  },
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  showUnselectedLabels: true,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Beranda',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: 'Pencarian',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorite',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ],
),

    );
  }
}
