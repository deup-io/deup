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

class PosterLayoutItem extends StatefulWidget {
  final ObjectModel object;

  const PosterLayoutItem({Key? key, required this.object}) : super(key: key);

  @override
  _PosterLayoutItemState createState() => _PosterLayoutItemState();
}

class _PosterLayoutItemState extends State<PosterLayoutItem> {
  ObjectModel get object => widget.object;
  final serverId = PluginRuntimeService.to.server?.id ?? '';

  /// 图片
  Widget _buildNetworkImage() {
    final _blob = CommonUtils.getBlobData(object.poster ?? '');
    return Hero(
      tag: '${object.id}',
      child: _blob != null
          ? Image.memory(_blob as Uint8List, fit: BoxFit.cover)
          : CachedNetworkImage(
              imageUrl: object.poster ?? '',
              fit: BoxFit.cover,
              memCacheWidth: 500,
              httpHeaders: ObjectHelper.getHeaders(object),
              placeholder: (context, url) => CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.wifi_exclamationmark,
                      size: CommonUtils.isPad ? 30 : 100.sp,
                      color: Colors.grey,
                    ),
                    Text(
                      object.name ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
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
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Color(0xFF2A2A2C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildNetworkImage(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: object.remark != null && object.remark!.isNotEmpty
                  ? Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        object.remark ?? '',
                        maxLines: 1,
                        style: Get.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
