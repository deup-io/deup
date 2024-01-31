import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/homepage/homepage_controller.dart';
import 'package:deup/pages/homepage/components/plugin_item_component.dart';

class Homepage extends GetView<HomepageController> {
  const Homepage({Key? key}) : super(key: key);

  /// NavigationBar
  Widget _buildSliverNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor:
          Get.isDarkMode ? Color.fromARGB(255, 18, 18, 18) : Colors.white,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(CupertinoIcons.settings, size: CommonUtils.navIconSize),
        onPressed: () => Get.toNamed(Routes.SETTING),
      ),
      largeTitle: Text(
        'Deup',
        style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.plus_circled, size: CommonUtils.navIconSize),
        onPressed: () => Get.toNamed(Routes.CODE_EDITOR),
      ),
    );
  }

  /// 没有设置任何插件
  Widget _buildEmptyPlugin() {
    return Column(
      children: [
        SizedBox(height: 500.h),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: CommonUtils.isPad ? 20 : 50.sp,
              ),
              SizedBox(width: 5.w),
              Text('了解更多'),
            ],
          ),
          onPressed: () => Get.toNamed(Routes.WEBVIEW, arguments: {
            'url': 'https://docs.deup.io/guide/quick-start',
            'title': 'Deup!',
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.r),
          child: ButtonHelper.createElevatedButton(
            '新建',
            onPressed: () => Get.toNamed(Routes.CODE_EDITOR),
          ),
        ),
      ],
    );
  }

  /// SliverList
  Widget _buildSliverList() {
    if (controller.isFirstLoading.isTrue) {
      return SliverToBoxAdapter(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    // 无插件信息
    if (controller.pluginList.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyPlugin());
    }

    return SizeCacheWidget(
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => FrameSeparateWidget(
            index: index,
            child: GestureDetector(
              onTap: () => controller.onPluginTap(controller.pluginList[index]),
              child: PluginItemComponent(
                index: index,
                plugin: controller.pluginList[index],
              ),
            ),
          ),
          childCount: controller.pluginList.length,
        ),
      ),
    );
  }

  // ScrollView
  // Replace to [NestedScrollView]
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      shrinkWrap: false,
      controller: controller.scrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: <Widget>[
        _buildSliverNavigationBar(),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.getPluginList();
            await Future.delayed(Duration(seconds: 1));
          },
        ),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 25 : 50.w)
                  .copyWith(bottom: 30.h),
          sliver: SliverToBoxAdapter(
            child: CupertinoSearchTextField(
              placeholder: '搜索',
              placeholderStyle: TextStyle(
                fontSize: 15,
                color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
              style: TextStyle(fontSize: 18),
              onChanged: (String value) {
                controller.keyword.value = value;
                controller.getPluginList();
              },
            ),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 25 : 50.w)
                  .copyWith(bottom: 30.h),
          sliver: Obx(() => _buildSliverList()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: CupertinoPageScaffold(
        child: _buildCustomScrollView(),
      ),
    );
  }
}
