import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/detail/detail_view.dart';
import 'package:deup/pages/plugin/plugin_controller.dart';
import 'package:deup/pages/plugin/components/server_item_component.dart';

class PluginPage extends GetView<PluginController> {
  const PluginPage({Key? key}) : super(key: key);

  /// NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text(
        controller.config.name ?? 'Untitled',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.plus, size: CommonUtils.navIconSize),
        onPressed: () => controller.addServerBottomSheet(),
      ),
    );
  }

  /// 没有设置服务信息
  Widget _buildEmptyServer() {
    return Column(
      children: [
        SizedBox(height: 500.h),
        Text('您还没有添加服务信息'),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 100.r),
          child: ButtonHelper.createElevatedButton(
            '添加',
            onPressed: () => controller.addServerBottomSheet(),
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

    // 无服务信息
    if (controller.serverList.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyServer());
    }

    return SizeCacheWidget(
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => FrameSeparateWidget(
            index: index,
            child: GestureDetector(
              onTap: () async {
                try {
                  SmartDialog.showLoading(msg: '初始化中...');
                  await PluginRuntimeService.to.initialize(
                    controller.plugin.script,
                    server: controller.serverList[index],
                  );
                  SmartDialog.dismiss();
                  Get.to(() => DetailPage(), routeName: '${Routes.DETAIL}');
                } catch (e) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast('初始化失败, 请重试');
                }
              },
              child: ServerItemComponent(
                index: index,
                server: controller.serverList[index],
              ),
            ),
          ),
          childCount: controller.serverList.length,
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
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.getServerList();
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
                controller.getServerList();
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
        navigationBar: _buildNavigationBar(),
        child: _buildCustomScrollView(),
      ),
    );
  }
}
