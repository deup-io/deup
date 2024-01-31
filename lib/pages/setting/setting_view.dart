import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:deup/common/index.dart';
import 'package:deup/storages/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/setting/setting_controller.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(FontAwesomeIcons.xmark, size: CommonUtils.navIconSize),
        onPressed: () => Get.back(),
      ),
      middle: Text('设置'),
    );
  }

  /// ListTile
  /// [title] 标题
  /// [icon] 图标
  /// [onTap] 点击事件
  /// [additionalInfo] 附加信息
  Widget _buildListTile({
    required String title,
    required IconData icon,
    double? iconSize,
    Color? iconColor,
    Function()? onTap,
    Widget trailing = const CupertinoListTileChevron(),
    String additionalInfo = '',
    bool isPremium = false,
  }) {
    return CupertinoListTile(
      title: Row(
        children: [
          Text(title, style: Get.textTheme.bodyLarge),
          SizedBox(width: 10),
          isPremium
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Pre',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      padding: EdgeInsets.only(left: 15, right: 10),
      leading: Icon(
        icon,
        size: iconSize ?? CommonUtils.navIconSize,
        color: iconColor ?? Get.theme.primaryColor,
      ),
      leadingToTitle: 5,
      additionalInfo: Container(
        width: 390.w,
        alignment: Alignment.centerRight,
        child: Text(
          additionalInfo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Container(
        height: Get.height,
        padding: EdgeInsets.only(bottom: 20.h),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              Obx(
                () => CupertinoListSection.insetGrouped(
                  backgroundColor: CommonUtils.backgroundColor,
                  dividerMargin: 20,
                  additionalDividerMargin: 30,
                  header: Container(
                    padding: EdgeInsets.only(left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text('通用', style: Get.textTheme.bodySmall),
                  ),
                  children: [
                    _buildListTile(
                      title: '个性化',
                      icon: Icons.color_lens,
                      additionalInfo: controller.themeModeText.value,
                      onTap: () => controller.changeTheme(),
                    ),
                    _buildListTile(
                      title: '下载管理',
                      icon: Icons.download_rounded,
                      onTap: () => Get.toNamed(Routes.SETTING_DOWNLOAD),
                    ),
                  ],
                ),
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: CommonUtils.backgroundColor,
                dividerMargin: 20,
                additionalDividerMargin: 30,
                header: Container(
                  padding: EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  child: Text('视频', style: Get.textTheme.bodySmall),
                ),
                footer: Container(
                  padding: EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '仅对视频播放生效, 如果视频卡顿可以尝试关闭硬件解码',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                children: [
                  _buildListTile(
                    title: '自动播放',
                    icon: Icons.play_circle_outline_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isAutoPlay.value,
                        onChanged: (value) {
                          controller.isAutoPlay.value = value;
                          Get.find<PreferencesStorage>().isAutoPlay.val = value;
                        },
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: '硬件解码',
                    icon: Icons.hardware_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isHardwareDecode.value,
                        onChanged: (value) {
                          controller.isHardwareDecode.value = value;
                          Get.find<PreferencesStorage>().isHardwareDecode.val =
                              value;
                        },
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: '后台播放',
                    icon: Icons.personal_video_rounded,
                    trailing: Obx(
                      () => CupertinoSwitch(
                        value: controller.isBackgroundPlay.value,
                        onChanged: (value) {
                          controller.isBackgroundPlay.value = value;
                          Get.find<PreferencesStorage>().isBackgroundPlay.val =
                              value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                backgroundColor: CommonUtils.backgroundColor,
                dividerMargin: 20,
                additionalDividerMargin: 30,
                children: [
                  _buildListTile(
                    title: '问题反馈',
                    icon: Icons.feedback_rounded,
                    onTap: () => launchUrl(
                      Uri.parse('https://github.com/deup-io/deup/issues'),
                    ),
                  ),
                  _buildListTile(
                    title: '免责条款',
                    icon: Icons.warning_rounded,
                    onTap: () => BrowserService.to
                        .open('https://docs.deup.io/agreement'),
                  ),
                  _buildListTile(
                    title: '评价',
                    icon: Icons.stars_rounded,
                    additionalInfo: '麻烦客官给个好评哦!',
                    onTap: () => controller.inAppReview.openStoreListing(
                      appStoreId: '1669407516',
                    ),
                  ),
                  _buildListTile(
                    title: '关于',
                    icon: Icons.info_rounded,
                    onTap: () => Get.toNamed(Routes.SETTING_ABOUT),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
