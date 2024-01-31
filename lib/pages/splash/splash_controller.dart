import 'dart:async';

import 'package:get/get.dart';
import 'package:fijkplayer/fijkplayer.dart';

import 'package:deup/common/index.dart';
import 'package:deup/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    // Jump to LandingPage after 10ms
    Timer(const Duration(milliseconds: 10), () => complete());
  }

  void complete() async {
    if (!CommonUtils.isPad) await FijkPlugin.setOrientationPortrait();

    // 跳转到首页
    Get.offAndToNamed(Routes.HOMEPAGE);
  }
}
