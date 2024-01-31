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

class CoverLayoutItem extends StatefulWidget {
  final ObjectModel object;

  const CoverLayoutItem({Key? key, required this.object}) : super(key: key);

  @override
  _CoverLayoutItemState createState() => _CoverLayoutItemState();
}

class _CoverLayoutItemState extends State<CoverLayoutItem> {
  ObjectModel get object => widget.object;
  final serverId = PluginRuntimeService.to.server?.id ?? '';

  /// 图片
  Widget _buildNetworkImage() {
    final _blob = CommonUtils.getBlobData(object.cover ?? '');
    return Hero(
      tag: '${object.id}',
      child: _blob != null
          ? Image.memory(_blob as Uint8List, fit: BoxFit.cover)
          : CachedNetworkImage(
              imageUrl: object.cover ?? '',
              fit: BoxFit.cover,
              memCacheWidth: 500,
              httpHeaders: ObjectHelper.getHeaders(object),
              placeholder: (context, url) => CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: CommonUtils.isPad ? 230 : 500.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF2A2A2C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: _buildNetworkImage(),
          ),
        ),
        SizedBox(height: CommonUtils.isPad ? 10 : 15.h),
        Text(
          object.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Get.textTheme.titleMedium,
        ),
      ],
    );
  }
}
