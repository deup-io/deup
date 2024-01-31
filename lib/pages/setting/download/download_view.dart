import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:deup/common/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/pages/setting/download/download_controller.dart';

class DownloadPage extends GetView<DownloadController> {
  const DownloadPage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
      middle: Text('下载管理'),
    );
  }

  /// 构建图标
  Widget _buildIcon(String type, String name) {
    return Icon(
      ObjectType.getIcon(type, name),
      size: CommonUtils.isPad ? 60 : 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 列表项
  Widget _buildItem(int index) {
    final task = controller.tasks[index];
    final entity = controller.entities.firstWhere(
      (e) => e.taskId == task.taskId,
    );

    String additionalInfo = task.progress == 100 ? '' : '${task.progress}%';
    if (task.status == DownloadTaskStatus.failed) additionalInfo = 'failed'.tr;

    return CupertinoListSection.insetGrouped(
      backgroundColor: CommonUtils.backgroundColor,
      margin: CommonUtils.isPad
          ? EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 5)
          : EdgeInsets.symmetric(horizontal: 50.w).copyWith(bottom: 30.h),
      children: [
        Container(
          height: CommonUtils.isPad ? 80 : 170.h,
          width: double.infinity,
          child: Slidable(
            startActionPane: task.status == DownloadTaskStatus.complete
                ? ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => Share.shareXFiles(
                            [XFile('${task.savedDir}/${entity.name}')]),
                        backgroundColor: CupertinoColors.systemBlue,
                        foregroundColor: Colors.white,
                        icon: CupertinoIcons.share,
                        label: '其他应用打开',
                      )
                    ],
                  )
                : null,
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                task.status == DownloadTaskStatus.running
                    ? SlidableAction(
                        onPressed: (context) =>
                            FlutterDownloader.pause(taskId: task.taskId),
                        backgroundColor: Colors.grey,
                        icon: CupertinoIcons.pause_circle,
                        foregroundColor: Colors.white,
                        label: '暂停',
                      )
                    : SizedBox(),
                task.status == DownloadTaskStatus.paused
                    ? SlidableAction(
                        onPressed: (context) =>
                            controller.resume(entity.id!, task.taskId),
                        backgroundColor: Get.theme.primaryColor,
                        icon: CupertinoIcons.play_circle,
                        foregroundColor: Colors.white,
                        label: '恢复',
                      )
                    : SizedBox(),
                SlidableAction(
                  onPressed: (context) =>
                      controller.delete(entity.id!, task.taskId),
                  backgroundColor: Colors.red,
                  icon: CupertinoIcons.delete,
                  label: '删除',
                ),
              ],
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.open(task, entity),
              child: Row(
                children: [
                  SizedBox(width: 30.w),
                  _buildIcon(entity.type, entity.name),
                  SizedBox(width: 20.w),
                  Container(
                    width: task.progress == 100 ? 750.w : 650.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: CommonUtils.isPad ? 15 : 30.h),
                        Text(
                          entity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          '${CommonUtils.formatFileSize(entity.size)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    additionalInfo,
                    style: Get.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// SliverList
  Widget _buildSliverList() {
    if (controller.isFirstLoading.isTrue) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 500.h),
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (controller.tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(height: 500.h),
            Icon(FontAwesomeIcons.solidFile, size: 170.r, color: Colors.grey),
            SizedBox(height: 30.h),
            Text('没有下载文件', style: Get.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => FrameSeparateWidget(
          index: index,
          child: Obx(() => _buildItem(index)),
        ),
        childCount: controller.tasks.length,
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
        SliverToBoxAdapter(
          child: controller.tasks.isNotEmpty
              ? Container(
                  padding: CommonUtils.isPad
                      ? EdgeInsets.only(left: 40, top: 30.h, bottom: 10.h)
                      : EdgeInsets.only(left: 80.w, top: 30.h, bottom: 10.h),
                  child: Obx(
                    () => Text(
                        '已用空间 ${CommonUtils.formatFileSize(controller.totalSize.value)}, 左滑管理文件',
                        style: Get.textTheme.bodySmall),
                  ),
                )
              : SizedBox(),
        ),
        Obx(() => SizeCacheWidget(child: _buildSliverList())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      backgroundColor: CommonUtils.backgroundColor,
      child: Obx(
        () => controller.isFirstLoading.isTrue
            ? Center(child: CupertinoActivityIndicator())
            : _buildCustomScrollView(),
      ),
    );
  }
}
