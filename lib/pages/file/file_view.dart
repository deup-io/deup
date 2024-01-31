import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/pages/file/file_controller.dart';

class FilePage extends GetView<FileController> {
  const FilePage({Key? key}) : super(key: key);

  // NavigationBar
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CommonUtils.backButton,
    );
  }

  /// 构建图标
  Widget _buildIcon() {
    return Icon(
      ObjectType.getIcon(controller.object.value.type ?? '',
          controller.object.value.name ?? ''),
      size: 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 文件信息
  Widget _buildFileInfo() {
    final fileSize = CommonUtils.formatFileSize(controller.object.value.size);

    return Column(
      children: [
        SizedBox(height: 200.h),
        _buildIcon(),
        SizedBox(height: 20.h),
        Text(
          controller.object.value.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodyLarge,
        ),
        SizedBox(height: 5.h),
        Text(
          '文件大小: ${fileSize}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }

  // 页面
  Widget _buildPageInfo() {
    if (controller.isLoading.isTrue) {
      return Center(child: CupertinoActivityIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: _buildFileInfo(),
          ),
          SizedBox(height: 500.h),
          Column(
            children: [
              Text(
                '暂不支持打开此类文件, 请添加到下载列表\n下载完成后, 可以使用其他应用打开并预览',
                style: Get.textTheme.bodySmall,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 100.r),
                child: ButtonHelper.createElevatedButton(
                  '下载',
                  onPressed: () => controller.download(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: Obx(() => _buildPageInfo()),
    );
  }
}
