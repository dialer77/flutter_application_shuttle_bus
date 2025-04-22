import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaverMapPage extends StatefulWidget {
  const NaverMapPage({super.key});

  @override
  State<NaverMapPage> createState() => _NaverMapPageState();
}

class _NaverMapPageState extends State<NaverMapPage> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이버 지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // 현재 위치로 이동
              _mapController?.updateCamera(
                NCameraUpdate.withParams(
                  target: const NLatLng(37.5666102, 126.9783881), // 임시로 서울시청 좌표 사용
                  zoom: 15,
                ),
              );
            },
          ),
        ],
      ),
      body: NaverMap(
        options: const NaverMapViewOptions(
          indoorEnable: true,
          locationButtonEnable: true,
          consumeSymbolTapEvents: false,
        ),
        onMapReady: (controller) {
          _mapController = controller;
        },
        onMapTapped: (point, latLng) {
          print('지도 탭: $latLng');
        },
        onSymbolTapped: (symbol) {
          print('심볼 탭: ${symbol.caption}');
        },
        onCameraChange: (reason, isGesture) {
          print('카메라 변경: $reason, 제스처: $isGesture');
        },
        onCameraIdle: () {
          print('카메라 이동 완료');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarker,
        child: const Icon(Icons.add_location),
      ),
    );
  }

  void _addMarker() async {
    if (_mapController == null) return;

    // 현재 카메라 위치에 마커 추가
    final cameraPosition = await _mapController!.getCameraPosition();
    final marker = NMarker(
      id: 'marker_${DateTime.now().millisecondsSinceEpoch}',
      position: cameraPosition.target,
    );

    marker.setOnTapListener((marker) {
      print('마커 탭: ${marker.info.id}');

      // 정보창 표시
      final infoWindow = NInfoWindow.onMarker(
        id: marker.info.id,
        text: '위치: ${marker.position.latitude}, ${marker.position.longitude}',
      );
      _mapController?.addOverlay(infoWindow);
    });

    _mapController?.addOverlay(marker);

    // 마커에 캡션 추가
    const caption = NOverlayCaption(
      text: '새 위치',
      textSize: 14,
      color: Colors.black,
      haloColor: Colors.white,
    );
    marker.setCaption(caption);
  }
}
