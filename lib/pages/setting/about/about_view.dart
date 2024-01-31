import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:deup/gen/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/pages/setting/about/about_controller.dart';

class AboutPage extends GetView<AboutController> {
  const AboutPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('关于'),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    CupertinoListTileChevron? trailing = const CupertinoListTileChevron(),
    String additionalInfo = '',
    Function()? onTap,
  }) {
    return CupertinoListTile(
      title: Text(title, style: Get.textTheme.bodyLarge),
      padding: EdgeInsets.only(left: 15, right: 10),
      leading: Icon(
        icon,
        size: CommonUtils.navIconSize,
        color: Get.theme.primaryColor,
      ),
      leadingToTitle: 5,
      additionalInfo: Container(
        width: 500.w,
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

  /// 信息
  Widget _buildInfo() {
    return Obx(
      () => CupertinoListSection.insetGrouped(
        backgroundColor: CommonUtils.backgroundColor,
        dividerMargin: 20,
        additionalDividerMargin: 30,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              controller.showVersion.toggle();
            },
            child: _buildListTile(
              title: '版本',
              icon: Icons.info_outline_rounded,
              additionalInfo: controller.showVersion.isTrue
                  ? 'v${controller.version.value}'
                  : '0x00000000',
              trailing: null,
            ),
          ),
          _buildListTile(
            title: 'GitHub',
            icon: Icons.code_rounded,
            additionalInfo: 'deup-io/deup',
            onTap: () => BrowserService.to.open(
              'https://github.com/deup-io/deup',
            ),
          ),
          _buildListTile(
            title: 'Telegram',
            icon: Icons.send_rounded,
            additionalInfo: 't.me/DeupGroup',
            onTap: () => launchUrl(
              Uri.parse('https://t.me/DeupGroup'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100.h),
                Center(
                    child: Get.isDarkMode
                        ? Assets.common.logoDarkTransparent.image(width: 900.w)
                        : Assets.common.logoTransparent.image(width: 900.w)),
                _buildInfo(),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: Get.isDarkMode
                        ? Assets.common.logoDarkTransparent.image(width: 300.w)
                        : Assets.common.logoTransparent.image(width: 300.w)),
                _buildInfo(),
              ],
            );
          }
        },
      ),
    );
  }
}
