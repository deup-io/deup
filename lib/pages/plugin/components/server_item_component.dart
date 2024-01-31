import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:deup/common/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/plugin/plugin_controller.dart';

class ServerItemComponent extends GetView<PluginController> {
  final int index;
  final ServerEntity server;

  const ServerItemComponent(
      {Key? key, required this.index, required this.server})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.h),
      children: [
        Container(
          height: CommonUtils.isPad ? 80 : 160.h,
          color: Get.isDarkMode ? Color(0xFF2A2A2C) : Colors.grey[100],
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: CommonUtils.isPad ? 25 : 50.w),
                  Icon(
                    FontAwesomeIcons.server,
                    size: CommonUtils.navIconSize,
                    color: Get.theme.primaryColor,
                  ),
                  SizedBox(width: CommonUtils.isPad ? 15 : 30.w),
                  Container(
                    width: 650.w,
                    child: Text(
                      '${server.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(right: CommonUtils.isPad ? 15 : 30.w),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerRight,
                  child: Icon(CupertinoIcons.ellipsis_vertical,
                      size: CommonUtils.isPad ? 25 : 60.sp),
                  onPressed: () => controller.moreActionSheet(server.id),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
