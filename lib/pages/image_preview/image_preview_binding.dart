import 'package:get/get.dart';

import 'package:deup/pages/image_preview/image_preview_controller.dart';

class ImagePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImagePreviewController>(() => ImagePreviewController());
  }
}
