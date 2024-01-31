import 'dart:convert';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/components/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/homepage/homepage_controller.dart';

class PluginItemComponent extends GetView<HomepageController> {
  final int index;
  final PluginEntity plugin;

  const PluginItemComponent(
      {Key? key, required this.index, required this.plugin})
      : super(key: key);

  /// 构建 logo
  ///
  /// [config] 插件配置
  Widget _buildLogoImage(PluginConfigModel config, Color? color) {
    if (config.logo == null || config.logo!.isEmpty) return SizedBox.shrink();

    // 获取文件后缀
    final _ext = p.extension(config.logo!).replaceAll('.', '').toLowerCase();

    // svg 特殊处理
    return Container(
      width: CommonUtils.isPad ? 65 : 150.r,
      height: CommonUtils.isPad ? 65 : 150.r,
      margin: EdgeInsets.only(right: CommonUtils.isPad ? 15 : 30.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: _ext == 'svg'
            ? CachedNetworkSvgImage(
                imageUrl: config.logo!,
                width: CommonUtils.isPad ? 65 : 150.r,
                height: CommonUtils.isPad ? 65 : 150.r,
                fit: BoxFit.cover,
                placeholder:
                    CupertinoActivityIndicator(radius: 8.0, color: color),
              )
            : CachedNetworkImage(
                imageUrl: config.logo!,
                width: CommonUtils.isPad ? 65 : 150.r,
                height: CommonUtils.isPad ? 65 : 150.r,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    CupertinoActivityIndicator(radius: 8.0, color: color),
                errorWidget: (context, url, error) => SizedBox.shrink(),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _config = PluginConfigModel.fromJson(json.decode(plugin.config));

    // 背景颜色
    final _background = (_config.background is List
            ? (_config.background as List).map((b) => b.toString()).toList()
            : [_config.background.toString(), _config.background.toString()])
        .where((b) => b != 'null')
        .toList();

    // 文字颜色
    final _color = CommonUtils.getHexColor(_config.color ??
        Get.theme.textTheme.bodyMedium!.color!.value.toRadixString(16));

    return Container(
      height: CommonUtils.isPad ? 90 : 180.h,
      margin: EdgeInsets.only(bottom: CommonUtils.isPad ? 10 : 20.h),
      decoration: _background.isNotEmpty
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _background.map((b) => CommonUtils.getHexColor(b)).toList(),
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              color: Get.isDarkMode ? Color(0xFF2A2A2C) : Colors.grey[100],
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: CommonUtils.isPad ? 20 : 30.w,
          vertical: CommonUtils.isPad ? 10 : 20.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogoImage(_config, _color),
                Container(
                  width: 600.w,
                  child: Text(
                    _config.name ?? 'Untitled',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _color,
                      fontSize: CommonUtils.isPad ? 25 : 50.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.topCenter,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                child: Icon(CupertinoIcons.ellipsis_circle, color: _color),
                onPressed: () => controller.moreActionSheet(plugin.id),
              ),
            )
          ],
        ),
      ),
    );
  }
}
