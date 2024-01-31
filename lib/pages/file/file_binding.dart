import 'package:get/get.dart';

import 'package:deup/pages/file/file_controller.dart';

class FileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileController>(() => FileController());
  }
}
