import 'package:get/get.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapViewModel extends GetxController {
  // 네이버 지도의 컨트롤러 (타입 명시)
  NaverMapController? naverController;

  // 지도가 이미 초기화되었는지 추적
  final RxBool isMapInitialized = false.obs;

  // 지도 초기화 메서드
  void initializeMap(NaverMapController controller) {
    if (!isMapInitialized.value) {
      naverController = controller;
      isMapInitialized.value = true;
      print('네이버 지도가 초기화되었습니다 - 첫 번째 로드');
    } else {
      print('네이버 지도가 이미 초기화되어 있습니다 - 재사용');
    }
  }

  // 지도 설정이나 마커 등을 관리하는 다른 메서드들...
}
