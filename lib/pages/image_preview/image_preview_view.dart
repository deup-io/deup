import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:deup/models/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/pages/image_preview/image_preview_controller.dart';

class ImagePreviewPage extends GetView<ImagePreviewController> {
  const ImagePreviewPage({Key? key}) : super(key: key);

  /// 加载动画
  Widget _buildLoading() => CupertinoActivityIndicator(radius: 13.0);

  /// 页面指示器
  Widget _buildExtendedPageIndicator() {
    return Positioned(
      left: 0,
      right: 50.r,
      bottom: 60.r,
      child: AnimatedOpacity(
        opacity: controller.isDragUpdate.value ? 0.0 : 1,
        duration: Duration(milliseconds: 300),
        child: Container(
          alignment: Alignment.bottomRight,
          child: Text(
            '${controller.currentIndex.value + 1}/${controller.objects.length}',
            style: Get.textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// 图片
  ///
  /// [index] 当前图片索引
  Future<Widget> _buildNetworkImage(int index) async {
    ObjectModel _object = controller.objects[index];

    // 如果没有原图地址, 请求 get 方法获取
    if (_object.url == null || _object.url!.isEmpty) {
      _object = await PluginRuntimeService.to.get(_object) ?? _object;
    }

    // blob 数据
    final _blob = CommonUtils.getBlobData(_object.url ?? '');
    return SingleChildScrollView(
      child: Hero(
        tag: _object.id ?? '',
        child: _blob != null
            ? Image.memory(_blob as Uint8List, fit: BoxFit.fitWidth)
            : CachedNetworkImage(
                imageUrl: _object.url ?? '',
                httpHeaders: ObjectHelper.getHeaders(_object),
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => _buildLoading(),
                errorWidget: (context, url, error) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.wifi_exclamationmark,
                        size: 100.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        error.toString(),
                        style: Get.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// 图片预览
  Widget _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      wantKeepAlive: true,
      pageController: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.objects.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions.customChild(
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 3.0,
          child: Center(
            child: FutureBuilder<Widget>(
              future: _buildNetworkImage(index),
              builder: (context, snapshot) {
                if (snapshot.hasData) return snapshot.data!;
                return _buildLoading();
              },
            ),
          ),
        );
      },
      backgroundDecoration: BoxDecoration(color: Colors.transparent),
      loadingBuilder: (context, event) => Center(child: _buildLoading()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Get.back(),
      isFullScreen: true,
      direction: DismissiblePageDismissDirection.vertical,
      backgroundColor: Colors.black,
      startingOpacity: 1.0,
      onDragUpdate: (details) {
        controller.isDragUpdate.value = details.opacity != 1.0;
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          onLongPress: () => controller.moreActionSheet(),
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Stack(
                children: [
                  _buildPhotoViewGallery(),
                  Obx(() => _buildExtendedPageIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
