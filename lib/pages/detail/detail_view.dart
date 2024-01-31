import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:deup/pages/plugin/plugin_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:deup/common/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/detail/layouts/index.dart';
import 'package:deup/pages/detail/detail_controller.dart';

class DetailPage extends StatelessWidget {
  final String? tag;
  DetailController get controller => Get.find<DetailController>(tag: tag);

  /// 构造函数
  DetailPage({Key? key, this.tag}) : super(key: key) {
    Get.put<DetailController>(DetailController(), tag: tag);
  }

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text(
        controller.history
            ? '历史记录'
            : controller.object?.name == null ||
                    controller.object!.name!.isEmpty
                ? controller.server.name
                : controller.object!.name!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Container(
        width: 300.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              onPressed: () => controller.switchLayoutType(),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              child: Icon(CupertinoIcons.rectangle_grid_1x2,
                  size: CommonUtils.isPad ? 22 : 65.sp),
            ),
            CupertinoButton(
              onPressed: () => Get.until(
                (route) => Get.currentRoute.startsWith(
                  Get.isRegistered<PluginController>()
                      ? Routes.PLUGIN
                      : Routes.HOMEPAGE,
                ),
              ),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              child: Icon(CupertinoIcons.xmark_circle_fill,
                  size: CommonUtils.navIconSize),
            )
          ],
        ),
      ),
    );
  }

  /// Layout
  Widget _buildLayout() {
    // 网格视图 - 全类型加载
    if (controller.layoutType.value == LayoutType.GRID)
      return GridLayout(
        id: controller.id,
        object: controller.object,
        history: controller.history,
        detailController: controller,
        keyword: controller.keyword.value,
      );

    // 图片视图 - 仅加载图片类型, 瀑布流
    if (controller.layoutType.value == LayoutType.IMAGE)
      return ImageLayout(
        id: controller.id,
        object: controller.object,
        history: controller.history,
        detailController: controller,
        keyword: controller.keyword.value,
      );

    // 封面视图 - 仅加载封面字段不为空的类型
    if (controller.layoutType.value == LayoutType.COVER)
      return CoverLayout(
        id: controller.id,
        object: controller.object,
        history: controller.history,
        detailController: controller,
        keyword: controller.keyword.value,
      );

    // 海报视图 - 仅加载海报字段不为空的类型
    if (controller.layoutType.value == LayoutType.POSTER)
      return PosterLayout(
        id: controller.id,
        object: controller.object,
        history: controller.history,
        detailController: controller,
        keyword: controller.keyword.value,
      );

    // 列表视图 - 默认
    return ListLayout(
      id: controller.id,
      object: controller.object,
      history: controller.history,
      detailController: controller,
      keyword: controller.keyword.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: _buildNavigationBar(),
        body: Obx(() => _buildLayout()),
        floatingActionButton: !controller.history && tag == null
            ? FloatingActionButton(
                onPressed: () => Get.to(
                  () => DetailPage(tag: '/history-identifier'),
                  routeName: '${Routes.DETAIL}/history-identifier',
                  arguments: {
                    'id': controller.id,
                    'history': true,
                    'object': controller.object
                  },
                ),
                mini: true,
                backgroundColor: Get.theme.primaryColor,
                child: Icon(Icons.history_rounded),
              )
            : null,
      ),
    );
  }
}
