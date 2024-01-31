import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:deup/storages/index.dart';
import 'package:deup/constants/index.dart';

class SettingController extends GetxController {
  final version = ''.obs; // 版本号

  // 自动播放
  final isAutoPlay = Get.find<PreferencesStorage>().isAutoPlay.val.obs;

  // 后台播放
  final isBackgroundPlay =
      Get.find<PreferencesStorage>().isBackgroundPlay.val.obs;

  // 硬件解码
  final isHardwareDecode =
      Get.find<PreferencesStorage>().isHardwareDecode.val.obs;

  // 主题
  final themeModeText = ''.obs;
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void onInit() async {
    super.onInit();

    // 获取当前版本号
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;

    // 获取当前主题模式
    themeModeText.value =
        ThemeModeTextMap[Get.find<CommonStorage>().themeMode.val]!;
  }

  /// 更换主题
  void changeTheme() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      actions: [
        SheetAction(label: '跟随系统', key: 'system'),
        SheetAction(label: '明亮', key: 'light'),
        SheetAction(label: '深邃', key: 'dark'),
      ],
      cancelLabel: '取消',
    );

    if (value != null) {
      Get.changeThemeMode(ThemeModeMap[value]!);
      themeModeText.value = ThemeModeTextMap[value]!;
      Get.find<CommonStorage>().themeMode.val = value;
      Future.delayed(Duration(milliseconds: 200), () {
        Get.forceAppUpdate();
      });
    }
  }
}
