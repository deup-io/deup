import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewController extends GetxController {
  final progress = 0.0.obs;
  final GlobalKey webViewKey = GlobalKey();

  final String url = Get.arguments['url'] ?? '';
  final String title = Get.arguments['title'] ?? '';

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
    transparentBackground: !Get.isDarkMode,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
  );

  @override
  void onInit() {
    super.onInit();
  }

  onWebViewCreated(controller) async {
    webViewController = controller;
  }

  onLoadStart(controller, url) {}

  onLoadStop(controller, url) {}

  onProgressChanged(controller, p) {
    progress.value = p / 100;
  }

  onConsoleMessage(controller, message) {
    print(message);
  }
}
