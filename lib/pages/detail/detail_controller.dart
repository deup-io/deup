import 'package:get/get.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/database/entity/index.dart';

class DetailController extends GetxController {
  final keyword = ''.obs;
  final layoutType = LayoutType.LIST.obs; // 布局方式
  final server = PluginRuntimeService.to.server!;

  // 获取参数
  String id = Get.arguments != null ? Get.arguments['id'] ?? '' : '';
  ObjectModel? object = Get.arguments != null ? Get.arguments['object'] : null;

  PluginEntity? get plugin => PluginRuntimeService.to.plugin;
  PluginConfigModel get pluginConfig => PluginRuntimeService.to.pluginConfig;

  // 是否是历史记录
  bool history =
      Get.arguments != null ? Get.arguments['history'] ?? false : false;

  @override
  void onInit() async {
    super.onInit();

    // 布局方式
    layoutType.value = getLayoutType().trim().toLowerCase();
  }

  /// 获取布局方式
  String getLayoutType() {
    if (history) // 历史记录
      return pluginConfig.historyLayout ??
          pluginConfig.layout ??
          LayoutType.LIST;

    // 如果设置了布局方式，则使用设置的布局方式
    if (object != null &&
        object!.options != null &&
        object!.options!.layout != null) return object!.options!.layout!;

    return pluginConfig.layout ?? LayoutType.LIST;
  }

  /// 切换布局方式
  void switchLayoutType() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      title: '布局方式 - ${LayoutType.getText(layoutType.value)}',
      actions: [
        SheetAction(label: '列表', key: LayoutType.LIST),
        SheetAction(label: '网格', key: LayoutType.GRID),
        SheetAction(label: '图片', key: LayoutType.IMAGE),
        SheetAction(label: '封面', key: LayoutType.COVER),
        SheetAction(label: '海报', key: LayoutType.POSTER),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;
    layoutType.value = value;
  }
}
