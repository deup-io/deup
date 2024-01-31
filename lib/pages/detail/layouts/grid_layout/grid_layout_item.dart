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

class GridLayoutItem extends StatefulWidget {
  final ObjectModel object;

  const GridLayoutItem({Key? key, required this.object}) : super(key: key);

  @override
  _GridLayoutItemState createState() => _GridLayoutItemState();
}

class _GridLayoutItemState extends State<GridLayoutItem> {
  ObjectModel get object => widget.object;
  final serverId = PluginRuntimeService.to.server?.id ?? '';

  /// 构建图标
  Widget _buildPreviewImage() {
    final _blob = CommonUtils.getBlobData(object.thumbnail ?? '');
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 65,
          height: 65,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                          CupertinoActivityIndicator(),
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
                    size: 20,
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
    if (object.thumbnail != null && object.thumbnail!.isNotEmpty) {
      return _buildPreviewImage();
    }

    return Icon(
      ObjectType.getIcon(object.type ?? ObjectType.UNKNOWN, object.name ?? ''),
      size: 65,
      color: Get.theme.primaryColor,
    );
  }

  /// 构建列表项
  Widget _buildTitleAndTime() {
    // 格式化时间
    final modified = object.modified == null
        ? ''
        : '${Jiffy.parseFromDateTime(object.modified!).format(pattern: 'yyyy/MM/dd')}';

    // 文件夹大小为 0 时显示 ∞
    final fileSize = (object.size == null || object.size == 0)
        ? '∞'
        : CommonUtils.formatFileSize(object.size);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            object.name ?? '',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 7.h),
        modified.isNotEmpty
            ? Text(
                modified,
                style: Get.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : SizedBox(),
        fileSize == '∞'
            ? SizedBox()
            : Text(
                fileSize,
                style: Get.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        SizedBox(height: 20.h),
        _buildTitleAndTime(),
      ],
    );
  }
}
