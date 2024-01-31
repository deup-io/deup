import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/helper/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImagePreviewController extends GetxController {
  // 获取参数
  String id = Get.arguments['id'] ?? '';
  List<ObjectModel> objects = Get.arguments['objects'] ?? [];

  // 图片控制器
  final currentIndex = 0.obs;
  final isDragUpdate = false.obs;
  late PageController pageController;
  final serverId = PluginRuntimeService.to.server?.id ?? '';

  @override
  void onInit() async {
    super.onInit();

    // 过滤非图片
    objects = objects
        .where((o) =>
            PreviewHelper.isImage(o.name ?? '') || o.type == ObjectType.IMAGE)
        .toList();

    // 初始化图片控制器
    currentIndex.value = objects.indexWhere((e) => e.id == id);
    pageController = PageController(initialPage: currentIndex.value);
  }

  /// 页面切换
  /// [index] 当前页面索引
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// 显示更多操作
  void moreActionSheet() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      actions: [
        SheetAction(label: '保存到相册', key: 'save'),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;
    if (value == 'save') await saveImage();
  }

  /// 保存图片
  Future<void> saveImage() async {
    try {
      SmartDialog.showLoading(msg: '保存中...');

      // 获取图片信息
      final _object = objects[currentIndex.value];
      final _file = await PluginRuntimeService.to.get(_object);
      if (_file == null || _file.url == null) throw '未获取到图片信息';

      // 下载图片
      final response = await DioService.to.dio.get(
        _file.url!,
        options: Options(
          responseType: ResponseType.bytes,
          headers: ObjectHelper.getHeaders(_file),
        ),
      );

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
      );

      SmartDialog.dismiss();
      if (result['isSuccess'] == false) throw '图片保存失败';
      SmartDialog.showToast('图片保存成功');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
    }
  }
}
