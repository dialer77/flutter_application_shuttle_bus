import 'package:flutter/material.dart';
import 'naver_map_page.dart'; // NaverMapPage를 import 합니다

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: const NaverMapPage(),
    );
  }
}
