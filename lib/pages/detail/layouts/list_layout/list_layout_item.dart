import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:deup/gen/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';

class ListLayoutItem extends StatefulWidget {
  final ObjectModel object;

  const ListLayoutItem({Key? key, required this.object}) : super(key: key);

  @override
  _ListLayoutItemState createState() => _ListLayoutItemState();
}

class _ListLayoutItemState extends State<ListLayoutItem> {
  ObjectModel get object => widget.object;
  final serverId = PluginRuntimeService.to.server?.id ?? '';

  /// 构建图标
  Widget _buildPreviewImage() {
    final _blob = CommonUtils.getBlobData(object.thumbnail ?? '');
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: CommonUtils.isPad ? 60 : 130.sp,
          height: CommonUtils.isPad ? 60 : 130.sp,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Hero(
              tag: '${object.id}',
              child: _blob != null
                  ? Image.memory(_blob as Uint8List, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: object.thumbnail!,
                      memCacheWidth: 500,
                      httpHeaders: ObjectHelper.getHeaders(object),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(radius: 8.0),
                      errorWidget: (context, url, error) =>
                          Assets.common.logo.image(),
                    ),
            ),
          ),
        ),
        (PreviewHelper.isVideo(object.name ?? '') ||
                object.type == ObjectType.VIDEO)
            ? Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Icon(
                    CupertinoIcons.video_camera_solid,
                    size: CommonUtils.isPad ? 20 : 35.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  /// 构建图标
  Widget _buildIcon() {
    if (object.options != null &&
        object.options!.icon != null &&
        object.options!.icon! == false) return SizedBox();

    // 预览图
    if (object.thumbnail != null && object.thumbnail!.isNotEmpty) {
      return _buildPreviewImage();
    }

    return Icon(
      ObjectType.getIcon(object.type ?? ObjectType.UNKNOWN, object.name ?? ''),
      size: CommonUtils.isPad ? 60 : 130.sp,
      color: Get.theme.primaryColor,
    );
  }

  /// 构建列表项
  Widget _buildTitleAndTime() {
    final modified = object.modified == null
        ? ''
        : '${Jiffy.parseFromDateTime(object.modified!).format(pattern: 'yyyy/MM/dd')} - ';

    // 文件夹大小为 0 时显示 ∞
    final description = (object.size == null || object.size == 0)
        ? '${modified}∞'
        : '${modified}${CommonUtils.formatFileSize(object.size)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: CommonUtils.isFolder(object) ? 750.w : 800.w,
          child: Text(
            object.name ?? '',
            maxLines: 2,
            style: Get.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        description == '∞'
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.only(top: 7.h),
                child: Text(description, style: Get.textTheme.bodySmall),
              ),
      ],
    );
  }

  /// 构建箭头
  Widget _buildChevron() {
    if (!CommonUtils.isFolder(object)) return SizedBox();
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: CupertinoListTileChevron(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: CommonUtils.isPad ? 5 : 20.r,
          bottom: CommonUtils.isPad ? 5 : 10.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(left: CommonUtils.isPad ? 15 : 30.w),
            child: Row(
              children: [
                _buildIcon(),
                SizedBox(width: CommonUtils.isPad ? 15 : 30.w),
                _buildTitleAndTime(),
              ],
            ),
          ),
          _buildChevron(),
        ],
      ),
    );
  }
}
