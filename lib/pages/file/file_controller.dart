import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';

class FileController extends GetxController {
  final object = ObjectModel().obs;
  final isLoading = true.obs; // 是否正在加载

  // 获取参数
  final String id = Get.arguments['id'] ?? '';

  @override
  void onInit() async {
    super.onInit();

    // 获取文件信息
    try {
      final _tmp = await PluginRuntimeService.to.get(
        Get.arguments['object'] ?? ObjectModel(),
      );
      if (_tmp == null) throw '无法获取对象信息';
      object.value = _tmp;
    } catch (e) {
      SmartDialog.showToast(e.toString());
      return;
    }

    // 绑定进度监听
    isLoading.value = false;
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
  }

  /// 下载文件
  void download() async {
    DownloadHelper.file(object.value);
  }

  @override
  void onClose() {
    super.onClose();

    // 取消进度监听
    DownloadService.to.unbindBackgroundIsolate();
  }
}
