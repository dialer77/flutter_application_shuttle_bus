import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_shuttle_bus/controllers/map_view_model.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_shuttle_bus/pages/single_page_app.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_shuttle_bus/services/synology_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:flutter_application_shuttle_bus/services/route_service.dart';

// 인증 정보를 로컬 파일에서 읽어오는 함수
Future<Map<String, dynamic>> loadAuthConfig() async {
  try {
    // 앱 문서 디렉토리에서 인증 설정 파일 경로 생성
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/auth_config.json');

    // 파일이 존재하는지 확인
    if (await file.exists()) {
      final contents = await file.readAsString();
      return json.decode(contents);
    }

    // 파일이 없을 경우 assets에서 기본 설정 로드
    try {
      final configString = await rootBundle.loadString('assets/config/auth_config.json');
      // 기본 설정을 로컬에 저장 (처음 실행 시)
      await file.writeAsString(configString);
      return json.decode(configString);
    } catch (e) {
      print('Assets에서 인증 설정 로드 실패: $e');
      // 기본값 반환
      return {
        'synology': {'quickConnectId': 'gimpoedu', 'username': 'gimpo1234', 'password': '12341234'}
      };
    }
  } catch (e) {
    print('인증 설정 로드 오류: $e');
    // 오류 시 기본값 반환
    return {
      'synology': {'quickConnectId': 'gimpoedu', 'username': 'gimpo1234', 'password': '12341234'}
    };
  }
}

// 인증 정보 저장 함수 (나중에 설정 화면 등에서 사용 가능)
Future<void> saveAuthConfig(Map<String, dynamic> config) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/auth_config.json');
    await file.writeAsString(json.encode(config));
    print('인증 설정이 저장되었습니다.');
  } catch (e) {
    print('인증 설정 저장 오류: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 기본 클라이언트 ID (fallback용)
  String naverClientId = '';

  // 인증 정보 로드
  final authConfig = await loadAuthConfig();
  final synologyConfig = authConfig['synology'] as Map<String, dynamic>;

  final quickConnectId = synologyConfig['quickConnectId'];
  final username = synologyConfig['username'];
  final password = synologyConfig['password'];

  // NAS에서 설정 파일 로드 시도
  try {
    final api = SynologyApi(quickConnectId);
    await api.login(username, password);

    // 설정 파일 경로를 확인하여 로드
    const configPath = '/Navigation/config.json'; // 적절한 경로로 수정 필요
    if (await api.fileExists(configPath)) {
      final jsonString = await api.getFile(configPath);
      final config = json.decode(jsonString);
      if (config['naverMap'] != null && config['naverMap']['clientId'] != null) {
        naverClientId = config['naverMap']['clientId'];
        print('NAS에서 네이버 클라이언트 ID 로드 성공: $naverClientId');
      }
    } else {
      print('설정 파일을 찾을 수 없습니다: $configPath');
    }

    await api.logout();
  } catch (e) {
    print('시놀로지 NAS 연결 오류: $e');
    print('기본 네이버 클라이언트 ID 사용: $naverClientId');
  }

  // GetX의 MapViewModel 등록
  Get.put(MapViewModel(), permanent: true);

  // 경로 서비스 초기화
  await Get.put(RouteService(), permanent: true).init();

  // 네이버 맵 초기화
  await FlutterNaverMap().init(
    clientId: naverClientId,
    onAuthFailed: (ex) => switch (ex) {
      NQuotaExceededException(:final message) => print("사용량 초과 (message: $message)"),
      NUnauthorizedClientException() || NClientUnspecifiedException() || NAnotherAuthFailedException() => print("인증 실패: $ex"),
    },
  );

  // GetX 스타일로 앱 실행
  runApp(const GetMaterialApp(
    title: '셔틀버스 앱',
    home: SinglePageApp(),
  ));
}
