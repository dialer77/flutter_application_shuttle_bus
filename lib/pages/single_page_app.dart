import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:flutter_application_shuttle_bus/controllers/map_view_model.dart';
import 'package:flutter_application_shuttle_bus/services/route_service.dart';

// 셔틀버스 옵션 관리를 위한 컨트롤러
class ShuttleController extends GetxController {
  // 현재 선택된 차량 (기본값: 1호차)
  final RxInt selectedBus = 1.obs;

  // 오전/오후 선택 (true: 오전, false: 오후)
  final RxBool isMorning = true.obs;

  // RouteService에서 버스 목록을 가져옴
  final RouteService _routeService = Get.find<RouteService>();

  // 사용 가능한 버스 목록
  List<int> get availableBuses => _routeService.getAvailableBusNumbers();

  // 버스 선택 메서드
  void selectBus(int busNumber) {
    selectedBus.value = busNumber;
  }

  // 오전/오후 전환 메서드
  void toggleTimeOfDay(bool morning) {
    isMorning.value = morning;
  }

  // 선택 변경 시 호출될 메서드 (나중에 지도 업데이트 등에 사용)
  void updateRoute() {
    print('노선 업데이트: ${selectedBus.value}호차, ${isMorning.value ? "오전" : "오후"}');
    // 경로 데이터 가져오기
    final routeData = _routeService.getRouteData(selectedBus.value, isMorning.value);
    if (routeData != null) {
      // 여기서 지도에 경로 표시 로직 구현
      print('경로 데이터 로드 성공');
    } else {
      print('경로 데이터 없음');
    }
  }
}

class SinglePageApp extends StatefulWidget {
  const SinglePageApp({super.key});

  @override
  State<SinglePageApp> createState() => _SinglePageAppState();
}

class _SinglePageAppState extends State<SinglePageApp> {
  // 현재 화면 상태 (메인 또는 지도)
  bool _showMap = false;

  // 맵 위젯은 한 번만 생성
  late final Widget _naverMapWidget;
  final MapViewModel _mapViewModel = Get.find<MapViewModel>();

  // RouteService 참조
  final RouteService _routeService = Get.find<RouteService>();

  // ShuttleController는 Get을 통해 접근 - 변수 선언 수정
  late final ShuttleController _shuttleController;

  @override
  void initState() {
    super.initState();

    // ShuttleController 초기화 - 여기에 직접 초기화 코드 추가
    _shuttleController = Get.put(ShuttleController());

    // 지도 위젯은 앱 시작 시 한 번만 생성
    _naverMapWidget = NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: true,
        locationButtonEnable: true,
        consumeSymbolTapEvents: false,
      ),
      onMapReady: (NaverMapController controller) {
        _mapViewModel.initializeMap(controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showMap ? '셔틀버스 노선도' : '메인 페이지'),
        // 지도 화면일 때만 뒤로가기 버튼 표시
        leading: _showMap
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showMap = false),
              )
            : null,
      ),
      body: Stack(
        children: [
          // 메인 화면 (지도가 보일 때는 숨김)
          Visibility(
            visible: !_showMap,
            maintainState: true, // 상태 유지
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() {
                // 경로 데이터가 로드되기 전에는 로딩 표시
                if (!_routeService.isLoaded.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('노선 데이터를 로드하는 중...'),
                      ],
                    ),
                  );
                }

                // 경로 데이터 로드 완료 후 UI 표시
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '셔틀버스 앱',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '노선을 선택한 후 지도를 확인하세요',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // 차량 선택 (먼저 배치)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '차량 선택',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _shuttleController.availableBuses.map((busNumber) {
                                  return ChoiceChip(
                                    label: Text('$busNumber호차'),
                                    selected: _shuttleController.selectedBus.value == busNumber,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _shuttleController.selectBus(busNumber);
                                        _shuttleController.updateRoute();
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 오전/오후 선택 (차량 선택 후)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '시간대 선택',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment<bool>(
                                    value: true,
                                    label: Text('오전'),
                                    icon: Icon(Icons.wb_sunny),
                                  ),
                                  ButtonSegment<bool>(
                                    value: false,
                                    label: Text('오후'),
                                    icon: Icon(Icons.nights_stay),
                                  ),
                                ],
                                selected: {_shuttleController.isMorning.value},
                                onSelectionChanged: (Set<bool> selected) {
                                  _shuttleController.toggleTimeOfDay(selected.first);
                                  _shuttleController.updateRoute();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 지도 열기 버튼
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showMap = true),
                      icon: const Icon(Icons.map),
                      label: Text(
                        '${_shuttleController.selectedBus.value}호차 ${_shuttleController.isMorning.value ? "오전" : "오후"} 노선 보기',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          // 지도 화면 (항상 생성되어 있지만 필요할 때만 보임)
          Visibility(
            visible: _showMap,
            maintainState: true, // 지도 상태 유지 (중요!)
            child: Stack(
              children: [
                // 한 번 생성된 지도 위젯
                _naverMapWidget,

                // 초기화 중일 때만 로딩 표시
                Obx(() {
                  if (!_mapViewModel.isMapInitialized.value) {
                    return Container(
                      color: Colors.white70,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                // 선택된 버스와 시간대 정보 표시
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(() {
                      if (!_routeService.isLoaded.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${_shuttleController.selectedBus.value}호차 ${_shuttleController.isMorning.value ? "오전" : "오후"} 노선',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
