import 'package:get/get.dart';

import 'package:deup/pages/setting/download/download_controller.dart';

class DownloadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadController>(() => DownloadController());
  }
}
