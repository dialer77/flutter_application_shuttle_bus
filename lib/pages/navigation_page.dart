import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // WebViewController 초기화
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 페이지 로딩 진행률 처리
          },
          onPageStarted: (String url) {
            // 페이지 로딩 시작 시 처리
          },
          onPageFinished: (String url) {
            // 페이지 로딩 완료 시 처리
          },
          onWebResourceError: (WebResourceError error) {
            // 에러 처리
          },
        ),
      )
      ..loadRequest(Uri.parse('https://map.naver.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이버 지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
