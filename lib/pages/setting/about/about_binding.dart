import 'package:get/get.dart';

import 'package:deup/pages/setting/about/about_controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AboutController>(AboutController());
  }
}
