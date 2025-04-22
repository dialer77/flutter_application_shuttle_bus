import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late NaverMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이버 지도'),
      ),
      // body: NaverMap(
      //   onMapCreated: onMapCreated,
      //   initialCameraPosition: const CameraPosition(
      //     target: LatLng(37.5666102, 126.9783881), // 서울시청
      //     zoom: 15,
      //   ),
      //   locationButtonEnable: true,
      //   indoorEnable: true,
      // ),
    );
  }

  void onMapCreated(NaverMapController controller) {
    _mapController = controller;
  }
}
