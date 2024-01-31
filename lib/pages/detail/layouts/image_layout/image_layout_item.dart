import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:deup/models/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';

class ImageLayoutItem extends StatefulWidget {
  final int index;
  final ObjectModel object;

  const ImageLayoutItem({Key? key, required this.object, required this.index})
      : super(key: key);

  @override
  _ImageLayoutItemState createState() => _ImageLayoutItemState();
}

class _ImageLayoutItemState extends State<ImageLayoutItem> {
  ObjectModel get object => widget.object;
  String get serverId => PluginRuntimeService.to.server?.id ?? '';

  String url = '';
  bool isFirstLoading = true; // 是否是第一次加载中

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // 初始化数据
  void _initialize() async {
    url = object.url ?? '';
    if (url.isEmpty) {
      final _file = await PluginRuntimeService.to.get(object);
      url = _file?.url ?? '';
    }
    isFirstLoading = false;
    if (mounted) setState(() {});
  }

  /// 图片
  Widget _buildNetworkImage() {
    if (isFirstLoading) return CupertinoActivityIndicator();

    // blob 数据
    final _blob = CommonUtils.getBlobData(url);
    if (_blob != null) {
      return Hero(
        tag: '${object.id}',
        child: Image.memory(_blob as Uint8List, fit: BoxFit.cover),
      );
    }

    return Hero(
      tag: '${object.id}',
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: 500,
        httpHeaders: ObjectHelper.getHeaders(object),
        placeholder: (context, url) => CupertinoActivityIndicator(),
        errorWidget: (context, url, error) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.wifi_exclamationmark,
                size: CommonUtils.isPad ? 30 : 100.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 10.h),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: 200.h),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Color(0xFF2A2A2C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: _buildNetworkImage(),
      ),
    );
  }
}
